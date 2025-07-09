import {ulid} from "ulid";

export function namespaceOf(of : 'created' | 'updated' | 'deleted' | string, namespace: EventNamespaces) {
    return `${namespace}.${of}`
}

export type EventNamespaces = "user" | "token" | "file"

export abstract class WineEvent {
    private readonly _eventId: string;
    private readonly _occurredAt: Date;
    private readonly _context: string;

    protected constructor(context: string) {
        this._context = context;
        this._occurredAt = new Date();
        this._eventId = ulid()
    }

    get eventId(): string {
        return this._eventId;
    }

    get occurredAt(): Date {
        return this._occurredAt;
    }

    get context(): string {
        return this._context;
    }
}