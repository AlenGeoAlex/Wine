export interface UserEvent {
    id: string;
}

export interface UserCreatedEvent extends UserEvent {
    userId: string;
    defaultToken: string | undefined;
}

export interface UserUpdatedEvent extends UserEvent  {
    id: string;
}

export interface UserDeletedEvent extends UserEvent  {

}