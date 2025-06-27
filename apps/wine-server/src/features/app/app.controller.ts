import {Controller, Get, HttpCode} from '@nestjs/common';

@Controller("api/v1/app")
export class AppController {

    @Get()
    @HttpCode(200)
    root(){
     return 'Hello World';
    }

}
