import {CallHandler, ExecutionContext, Injectable, mixin, NestInterceptor, Type,} from '@nestjs/common';
import {FileInterceptor} from '@nestjs/platform-express';
import {memoryStorage} from 'multer';
import {ConfigService} from '@nestjs/config';

export function CustomFileInterceptor(fieldName = 'file'): Type<NestInterceptor> {
    @Injectable()
    class MixinInterceptor implements NestInterceptor {
        private readonly fileInterceptor: NestInterceptor;

        constructor(private readonly configService: ConfigService) {
            const maxFileSize = this.configService.get<number>('MAX_FILE_SIZE') ?? 100 * 1024 * 1024;
            const InterceptorClass = FileInterceptor(fieldName, {
                storage: memoryStorage(),
                limits: { fileSize: maxFileSize },
            });

            this.fileInterceptor = new InterceptorClass() as NestInterceptor;
        }

        async intercept(context: ExecutionContext, next: CallHandler) {
            return this.fileInterceptor.intercept(context, next);
        }
    }

    return mixin(MixinInterceptor);
}