import {WineEvent} from "@common/events";

export abstract class FileEvent extends WineEvent {
    private readonly _fileId: string;

    protected constructor(context: string, fileId: string) {
        super(context);
        this._fileId = fileId;
    }

    public get fileId() {
        return this._fileId;
    }
}

export class FileCreatedEvent extends FileEvent {

    private readonly _isSecure: boolean;
    private readonly _fileType: string;

    constructor(fileId: string, context: string, isSecure: boolean, fileType: string) {
        super(context, fileId);
    }


    public get isSecure(): boolean {
        return this._isSecure;
    }

    public get fileType(): string {
        return this._fileType;
    }
}

export class FileDeletedEvent extends FileEvent {
    constructor(fileId: string, context: string) {
        super(context, fileId);
    }
}