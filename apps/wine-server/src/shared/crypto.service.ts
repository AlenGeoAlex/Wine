import { Injectable } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import {ConfigService} from "@nestjs/config";

@Injectable()
export class CryptoService {

    constructor(
        private readonly configService: ConfigService,
    ) {}

    private readonly saltRounds = 10; // Or load from config

    /**
     * Hashes a plaintext string.
     * @param plaintext The string to hash.
     * @returns A promise that resolves to the hashed string.
     */
    async hash(plaintext: string): Promise<string> {
        return bcrypt.hash(plaintext, this.saltRounds);
    }

    /**
     * Compares a plaintext string against a hash.
     * @param plaintext The plaintext string to check.
     * @param hash The hash to compare against.
     * @returns A promise that resolves to true if they match, otherwise false.
     */
    async compare(plaintext: string, hash: string): Promise<boolean> {
        return bcrypt.compare(plaintext, hash);
    }
}