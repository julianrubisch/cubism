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
<slot name="template"></slot>
<slot name="content"></slot>
`

    this.subscribeTrigger = this.getAttribute('subscribe-trigger')
    this.unsubscribeTrigger = this.getAttribute('unsubscribe-trigger')
    this.triggerRootSelector = this.getAttribute('trigger-root')
    this.triggerRoot = this

    this.addEventListener('cubism:update', this.update.bind(this))
  }

  async connectedCallback () {
    if (this.preview) return
    this.consumer = await CableReady.consumer

    this.channel = this.createSubscription()

    if (this.triggerRootSelector) {
      this.triggerRoot = document.querySelector(this.triggerRootSelector)
    }

    if (this.trigger === 'connect') {
      this.appear()
    } else {
      this.triggerRoot.addEventListener(this.subscribeTrigger, () => {
        this.appear()
      })
    }

    if (this.unsubscribeTrigger) {
      this.triggerRoot.addEventListener(this.unsubscribeTrigger, () => {
        if (this.channel) {
          this.disappear()
        }
      })
    }
  }

  disconnectedCallback () {
    this.disappear()
    super.disconnectedCallback()
  }

  appear () {
    this.channel.send({
      type: 'appear'
    })
  }

  disappear () {
    this.channel.send({
      type: 'disappear'
    })
  }

  performOperations (data) {
    if (data.cableReady) CableReady.perform(data.operations)
  }

  createSubscription (receivedCallback) {
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
        received: this.performOperations
      }
    )
  }

  update ({ detail }) {
    const template = this.shadowRoot
      .querySelector('slot[name=template]')
      .assignedElements()[0]

    this.querySelectorAll('[slot=content]').forEach(element => {
      element.remove()
    })

    detail.users.forEach(user => {
      const templateClone = template.content.cloneNode(true)

      for (const attribute in user) {
        templateClone
          .querySelectorAll(`[data-cubicle-attribute=${attribute}]`)
          .forEach(element => {
            element.innerHTML = user[attribute]
          })
      }

      templateClone.firstElementChild.slot = 'content'
      this.appendChild(templateClone.firstElementChild)
    })
  }

  get channelName () {
    return 'Cubism::PresenceChannel'
  }
}
