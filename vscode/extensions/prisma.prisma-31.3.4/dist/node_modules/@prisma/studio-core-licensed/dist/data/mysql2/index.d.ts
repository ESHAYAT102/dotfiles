import { Pool } from 'mysql2/promise';
import { S as SequenceExecutor } from '../../index-BhPjNuvP.js';
import 'kysely';

declare function createMySQL2Executor(pool: Pool): SequenceExecutor;

export { createMySQL2Executor };
