export interface TokenEvents {
    id: string;
}

export interface TokenCreatedEvent extends TokenEvents {

}

export interface TokenDeletedEvent extends TokenEvents {

}

export interface TokenUpdatedEvent extends TokenEvents {

}

export interface TokenRevokedEvent extends TokenEvents {
    revokedBy : 'user' | 'token'
}