import CableReady from 'cable_ready'
import { SubscribingElement } from 'cable_ready'

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
  }

  async connectedCallback () {
    if (this.preview) return

    this.appearTrigger = this.getAttribute('appear-trigger')
    this.disappearTrigger = this.getAttribute('disappear-trigger')
    this.triggerRootSelector = this.getAttribute('trigger-root')

    this.consumer = await CableReady.consumer

    this.channel = this.createSubscription()

    if (this.triggerRootSelector) {
      this.triggerRoot = document.querySelector(this.triggerRootSelector)
    }
  }

  disconnectedCallback () {
    this.disappear()
    super.disconnectedCallback()
  }

  install () {
    if (this.appearTrigger === 'connect') {
      this.appear()
    } else {
      this.triggerRoot.addEventListener(
        this.appearTrigger,
        this.appear.bind(this)
      )
    }

    if (this.disappearTrigger) {
      this.triggerRoot.addEventListener(
        this.disappearTrigger,
        this.disappear.bind(this)
      )
    }
  }

  uninstall () {
    if (this.appearTrigger !== 'connect') {
      this.triggerRoot.removeEventListener(
        this.appearTrigger,
        this.appear.bind(this)
      )
    }

    if (this.disappearTrigger) {
      this.triggerRoot.removeEventListener(
        this.disappearTrigger,
        this.disappear.bind(this)
      )
    }
  }

  appear () {
    if (this.channel) this.channel.perform('appear')
  }

  disappear () {
    if (this.channel) this.channel.perform('disappear')
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
        user: this.getAttribute('user'),
        element_id: this.id,
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
