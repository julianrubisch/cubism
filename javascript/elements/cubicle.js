import CableReady from 'cable_ready'
import { SubscribingElement } from 'cable_ready'

export class Cubicle extends SubscribingElement {
  async connectedCallback () {
    if (this.preview) return
    const consumer = await CableReady.consumer
    if (consumer) {
      this.createSubscription(
        consumer,
        'Cubism::PresenceChannel',
        this.performOperations
      )
    } else {
      console.error(
        'The `cubicle-element` helper cannot connect without an ActionCable consumer.'
      )
    }
  }

  performOperations (data) {
    if (data.cableReady) CableReady.perform(data.operations)
  }
}
