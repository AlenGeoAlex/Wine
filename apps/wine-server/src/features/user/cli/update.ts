import {CommandRunner, SubCommand} from "nest-commander";

@SubCommand({ name: 'update', arguments: '[phooey]' })
export class UpdateUserCommand extends CommandRunner {
    run(passedParams: string[], options?: Record<string, any>): Promise<void> {
        return Promise.resolve(undefined);
    }
    // command runner implementation
}