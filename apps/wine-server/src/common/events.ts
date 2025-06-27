export function namespaceOf(of : 'created' | 'updated' | 'deleted' | string, namespace: EventNamespaces) {
    return `${namespace}.${of}`
}

export type EventNamespaces = "user" | "token" | "upload"