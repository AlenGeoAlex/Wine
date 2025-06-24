import {CommandRunner, SubCommand} from "nest-commander";

@SubCommand({ name: 'delete', arguments: '[phooey]' })
export class DeleteUserCommand extends CommandRunner {
    run(passedParams: string[], options?: Record<string, any>): Promise<void> {
        return Promise.resolve(undefined);
    }
    // command runner implementation
}