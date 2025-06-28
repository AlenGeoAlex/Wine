import {Injectable, Logger, NestMiddleware} from '@nestjs/common';
import {TokenService} from "@features/token/token.service";
import {ClsService} from "nestjs-cls";
import {CONSTANTS} from "@common/constants";

@Injectable()
export class ApiUserMiddlewareMiddleware implements NestMiddleware {

  private readonly logger = new Logger(ApiUserMiddlewareMiddleware.name);
  private readonly tokenPrefix = "Token ";
  private readonly tokenSubStringLength = this.tokenPrefix.length;

  constructor(
      private readonly tokenService : TokenService,
      private readonly cls: ClsService
  ) {
  }

  async use(req: any, res: any, next: () => void) {
    const header = req.headers['authorization'] as string;
    if(!header){
      this.logger.log("No authorization header found, skipping it");
      return next();
    }

    let key : string | undefined;
    if(header.startsWith(this.tokenPrefix)){
      key = header.substring(this.tokenSubStringLength)
    }

    if(!key)
    {
      this.logger.log(`Failed to parse the token ${header}`)
      return next();
    }

    const userIdByToken = await this.tokenService.getUserIdByToken(key);

    if(!userIdByToken){
      return next();
    }

    if(userIdByToken.expiresAt){
      if(userIdByToken.expiresAt.getTime() < Date.now()){
        this.logger.log("Token expired, skipping it");
        return next();
      }
    }

    this.logger.log(`Found user with id ${userIdByToken.userId}`);
    this.cls.set(CONSTANTS.MIDDLEWARE_KEYS.API_KEY_USER, userIdByToken.userId);
    next();
  }
}
