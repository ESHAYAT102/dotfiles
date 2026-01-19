import { Sql } from 'postgres';
import { c as Executor } from '../../index-BhPjNuvP.js';
import 'kysely';

declare function createPostgresJSExecutor(postgresjs: Sql): Executor;

export { createPostgresJSExecutor };
