import {Injectable, Logger, Scope} from '@nestjs/common';
import {EventEmitter2} from "@nestjs/event-emitter";
import {WineEvent} from "@common/events";

@Injectable({
    scope: Scope.REQUEST
})
export class TransactionalEventCollectorService {

    private readonly logger = new Logger(TransactionalEventCollectorService.name);
    private readonly events: QueuedEvent[] = [];

    constructor(
        private readonly eventEmitter: EventEmitter2
    ) {
    }

    public queue(namespace: string, event: WineEvent)  {
        this.events.push({
            namespace: namespace,
            event: event
        })
    }

    public queueIf(namespace: string, event: WineEvent, callback: () => boolean | Promise<boolean> )  {
        try {
            const result = callback();
            if(result instanceof Promise)
                result.then(r => {
                    if(r)
                        this.queue(namespace, event);
                }).catch((err) => {
                    this.logger.error("Failed to check if event should be queued", err);
                })
            else if(result)
                this.queue(namespace, event);
        }catch (e) {
            this.logger.error("Failed to check if event should be queued", e);
        }
    }

    public dispatch() {
        this.events.forEach(event => {
            try {
                this.eventEmitter.emit(event.namespace, event.event);
            }catch (e) {
                this.logger.error("Failed to dispatch event", e);
            }
        })
        this.events.length = 0;
    }
}

export interface QueuedEvent {
    namespace: string;
    event : WineEvent
}