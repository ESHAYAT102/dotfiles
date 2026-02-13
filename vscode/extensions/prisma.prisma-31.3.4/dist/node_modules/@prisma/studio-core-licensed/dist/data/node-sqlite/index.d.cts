import { DatabaseSync } from 'node:sqlite';
import { c as Executor } from '../../index-BhPjNuvP.cjs';
import 'kysely';

declare function createNodeSQLiteExecutor(database: DatabaseSync): Executor;

export { createNodeSQLiteExecutor };
