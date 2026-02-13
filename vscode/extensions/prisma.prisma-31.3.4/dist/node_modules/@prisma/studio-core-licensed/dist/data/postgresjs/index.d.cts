import { Sql } from 'postgres';
import { c as Executor } from '../../index-BhPjNuvP.cjs';
import 'kysely';

declare function createPostgresJSExecutor(postgresjs: Sql): Executor;

export { createPostgresJSExecutor };
