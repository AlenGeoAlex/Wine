import {Injectable} from '@nestjs/common';
import {ConfigService} from "@nestjs/config";
import {GetObjectCommand, HeadBucketCommand, PutObjectCommand, S3Client} from "@aws-sdk/client-s3";
import {CONSTANTS} from "@common/constants";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

@Injectable()
export class S3Service {

    private s3Client? : S3Client;

    constructor(
        private readonly configService: ConfigService,
    ) {

    }

    public async generatePresignedUrl(key: string, expiresIn: number, action: 'GET' | 'POST'): Promise<string> {
        const client = await this.getOrCreateClient();

        const command = action === 'GET' ? new GetObjectCommand({
            Bucket: CONSTANTS.CONFIG_KEYS.STORAGE.S3.S3_BUCKET,
            Key: key,
        }) : new PutObjectCommand({
            Bucket: CONSTANTS.CONFIG_KEYS.STORAGE.S3.S3_BUCKET,
            Key: key,
        })

        try {
            return await getSignedUrl(client, command, {expiresIn});
        } catch (error) {
            console.error("Error generating pre-signed URL:", error);
            throw new Error("Failed to generate pre-signed URL");
        }
    }

    private async checkBucket(client: S3Client) : Promise<void> {
        const bucketCommand = new HeadBucketCommand({
            Bucket: CONSTANTS.CONFIG_KEYS.STORAGE.S3.S3_BUCKET,
        });

        try {
            await client.send(bucketCommand);
        } catch (error: any) {
            if (error.name === 'NotFound') {
                throw new Error("Bucket does not exist");
            } else if (error.name === 'Forbidden') {
                throw new Error("You do not have permission to access the bucket");
            } else {
                console.error('Error checking bucket:', error);
                throw error;
            }
        }
    }

    private async getOrCreateClient() : Promise<S3Client> {
        if(!this.s3Client){
            this.s3Client = await this.createS3Client();
        }

        return this.s3Client;
    }

    private async createS3Client() : Promise<S3Client> {
        const endpoint = CONSTANTS.CONFIG_KEYS.STORAGE.S3.S3_ENDPOINT;
        const region = CONSTANTS.CONFIG_KEYS.STORAGE.S3.S3_REGION;

        if(!endpoint && !region){
            throw new Error("S3 endpoint or region are required");
        }

        const accesskey = CONSTANTS.CONFIG_KEYS.STORAGE.S3.S3_ACCESS_KEY;
        const secretKey = CONSTANTS.CONFIG_KEYS.STORAGE.S3.S3_SECRET_KEY;

        if(!accesskey || !secretKey){
            throw new Error("S3 access key and secret key are required");
        }

        if(!CONSTANTS.CONFIG_KEYS.STORAGE.S3.S3_BUCKET){
            throw new Error("S3 bucket is required");
        }

        const s3Client = new S3Client({
            endpoint: endpoint,
            region: region,
            credentials: {
                accessKeyId: accesskey,
                secretAccessKey: secretKey
            },
        });
        await this.checkBucket(s3Client);
        return s3Client;
    }

}
