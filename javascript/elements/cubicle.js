/* eslint-disable no-undef */
import CableReady, { SubscribingElement } from 'cable_ready'
import { debounce } from 'cable_ready/javascript/utils'

export class Cubicle extends SubscribingElement {
  constructor () {
    super()
    const shadowRoot = this.attachShadow({ mode: 'open' })
    shadowRoot.innerHTML = `
<style>
  :host {
    display: block;
  }
</style>
<slot></slot>
`

    this.triggerRoot = this
    this.present = false
  }

  async connectedCallback () {
    if (this.preview) return

    this.appear = debounce(this.appear.bind(this), 50)

    this.appearTriggers = this.getAttribute('appear-trigger')
      ? this.getAttribute('appear-trigger').split(',')
      : []
    this.disappearTriggers = this.getAttribute('disappear-trigger')
      ? this.getAttribute('disappear-trigger').split(',')
      : []
    this.triggerRootSelector = this.getAttribute('trigger-root')

    this.consumer = await CableReady.consumer

    this.channel = this.createSubscription()

    this.appearanceIntersectionObserver = new IntersectionObserver(
      (entries, observer) => {
        entries.forEach(entry => {
          if (entry.target !== this.triggerRoot) return
          if (entry.isIntersecting) {
            if (!this.present) {
              this.appear()
            }
          } else {
            if (this.present) {
              this.disappear()
            }
          }
        })
      },
      { threshold: 0 }
    )

    this.mutationObserver = new MutationObserver((mutationsList, observer) => {
      if (this.triggerRootSelector) {
        // eslint-disable-next-line no-unused-vars
        for (const mutation of mutationsList) {
          const root = document.querySelector(this.triggerRootSelector)
          if (root) {
            this.uninstall()
            this.triggerRoot = root
            this.install()
          }
        }
      }
      this.mutationObserver.disconnect()
    })

    this.mutationObserver.observe(document, {
      subtree: true,
      childList: true
    })
  }

  disconnectedCallback () {
    this.disappear()
    super.disconnectedCallback()
  }

  install () {
    if (this.appearTriggers.includes('connect')) {
      this.appear()
    }

    this.appearTriggers
      .filter(eventName => eventName === 'intersect')
      .forEach(() => {
        this.appearanceIntersectionObserver.observe(this.triggerRoot)
      })

    this.appearTriggers
      .filter(eventName => eventName !== 'connect' && eventName !== 'intersect')
      .forEach(eventName => {
        this.triggerRoot.addEventListener(eventName, this.appear.bind(this))
      })

    this.disappearTriggers
      .filter(
        eventName => eventName !== 'disconnect' && eventName !== 'intersect'
      )
      .forEach(eventName => {
        this.triggerRoot.addEventListener(eventName, this.disappear.bind(this))
      })

    this.disappearTriggers
      .filter(eventName => eventName === 'intersect')
      .forEach(() => {})
  }

  uninstall () {
    this.appearTriggers
      .filter(eventName => eventName === 'intersect')
      .forEach(() => {
        this.appearanceIntersectionObserver.unobserve(this.triggerRoot)
      })

    this.appearTriggers
      .filter(eventName => eventName !== 'connect' && eventName !== 'intersect')
      .forEach(eventName => {
        this.triggerRoot.removeEventListener(eventName, this.appear.bind(this))
      })

    this.disappearTriggers
      .filter(eventName => eventName === 'intersect')
      .forEach(() => {})

    this.disappearTriggers
      .filter(
        eventName => eventName !== 'disconnect' && eventName !== 'intersect'
      )
      .forEach(eventName => {
        this.triggerRoot.removeEventListener(
          eventName,
          this.disappear.bind(this)
        )
      })
  }

  appear () {
    if (this.channel) {
      this.present = true
      this.channel.perform('appear')
    }
  }

  disappear () {
    if (this.channel) {
      this.present = false
      this.channel.perform('disappear')
    }
  }

  performOperations (data) {
    if (data.cableReady) {
      CableReady.perform(data.operations)
    }
  }

  createSubscription () {
    if (!this.consumer) {
      console.error(
        'The `cubicle-element` helper cannot connect without an ActionCable consumer.'
      )
      return
    }

    return this.consumer.subscriptions.create(
      {
        channel: this.channelName,
        identifier: this.getAttribute('identifier'),
        element_id: this.id,
        scope: this.getAttribute('scope'),
        exclude_current_user:
          this.getAttribute('exclude-current-user') === 'true'
      },
      {
        connected: () => {
          this.install()
        },
        disconnected: () => {
          this.disappear()
          this.uninstall()
        },
        rejected: () => {
          this.uninstall()
        },
        received: this.performOperations.bind(this)
      }
    )
  }

  get channelName () {
    return 'Cubism::PresenceChannel'
  }
}
