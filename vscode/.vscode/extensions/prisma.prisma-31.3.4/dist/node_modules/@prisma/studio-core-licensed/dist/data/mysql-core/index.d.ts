import { d as AdapterRequirements, S as SequenceExecutor, A as Adapter, T as Table, F as FilterOperator, Q as Query, f as AdapterDeleteDetails, B as BuilderRequirements, h as AdapterUpdateDetails, e as AdapterQueryDetails } from '../../index-BhPjNuvP.js';
import { OkPacketParams } from 'mysql2';
import * as kysely from 'kysely';

type MySQLAdapterRequirements = Omit<AdapterRequirements, "executor"> & {
    executor: SequenceExecutor;
};
declare function createMySQLAdapter(requirements: MySQLAdapterRequirements): Adapter;
/**
 * For testing purposes.
 */
declare function mockIntrospect(): {
    schemas: { [K in "studio"]: {
        name: K;
        tables: { [T in "animals" | "users"]: Table; };
    }; };
    timezone: "UTC";
    filterOperators: FilterOperator[];
    query: Query;
};

declare function getDeleteQuery(details: AdapterDeleteDetails, requirements?: Omit<BuilderRequirements, "Adapter" | "QueryCompiler">): Query<{
    affectedRows?: number | undefined;
    insertId?: number | undefined;
    serverStatus?: number | undefined;
    warningCount?: number | undefined;
    message?: string | undefined;
}>;
declare function getInsertQuery(details: {
    rows: Record<string, unknown>[];
    table: Table;
}, requirements?: Omit<BuilderRequirements, "Adapter" | "QueryCompiler">): Query<OkPacketParams>;
declare function getInsertRefetchQuery(details: {
    criteria: Record<string, unknown>[];
    table: Table;
}, requirements?: Omit<BuilderRequirements, "Adapter" | "QueryCompiler">): Query<{
    [x: string]: unknown;
    __ps_inserted_at__: string | number;
}>;
declare function getUpdateRefetchQuery(details: AdapterUpdateDetails, requirements?: Omit<BuilderRequirements, "Adapter" | "QueryCompiler">): Query<{
    [x: string]: unknown;
    __ps_updated_at__: string | number;
}>;
declare function getSelectQuery(details: AdapterQueryDetails, requirements?: Omit<BuilderRequirements, "Adapter" | "QueryCompiler">): Query<{
    [x: string]: unknown;
    __ps_count__: `${bigint}`;
}>;
/**
 * For testing purposes.
 */
declare function mockSelectQuery(): [];
declare function getUpdateQuery(details: AdapterUpdateDetails, requirements?: Omit<BuilderRequirements, "Adapter" | "QueryCompiler">): Query<{
    affectedRows?: number | undefined;
    insertId?: number | undefined;
    serverStatus?: number | undefined;
    warningCount?: number | undefined;
    message?: string | undefined;
}>;

declare function getTablesQuery(requirements?: Omit<BuilderRequirements, "Adapter" | "QueryCompiler">): Query<{
    name: string;
    schema: string;
    type: "BASE TABLE" | "VIEW";
    columns: {
        name: string;
        datatype: string;
        position: number;
        fk_table: string | null;
        fk_column: string | null;
        autoincrement: kysely.SqlBool;
        computed: kysely.SqlBool;
        pk: kysely.SqlBool;
        nullable: kysely.SqlBool;
    }[];
}>;
declare function mockTablesQuery(): [{
    readonly columns: [{
        readonly autoincrement: 1;
        readonly computed: 0;
        readonly datatype: "int";
        readonly fk_column: null;
        readonly fk_table: null;
        readonly name: "id";
        readonly nullable: 0;
        readonly pk: 1;
        readonly position: 1;
    }, {
        readonly autoincrement: 0;
        readonly computed: 0;
        readonly datatype: "binary(16)";
        readonly fk_column: null;
        readonly fk_table: null;
        readonly name: "uuid";
        readonly nullable: 1;
        readonly pk: 0;
        readonly position: 2;
    }, {
        readonly autoincrement: 0;
        readonly computed: 0;
        readonly datatype: "varchar(255)";
        readonly fk_column: null;
        readonly fk_table: null;
        readonly name: "name";
        readonly nullable: 1;
        readonly pk: 0;
        readonly position: 3;
    }, {
        readonly autoincrement: 0;
        readonly computed: 1;
        readonly datatype: "text";
        readonly fk_column: null;
        readonly fk_table: null;
        readonly name: "id_name";
        readonly nullable: 1;
        readonly pk: 0;
        readonly position: 4;
    }];
    readonly name: "animals";
    readonly schema: "studio";
    readonly type: "BASE TABLE";
}, {
    readonly columns: [{
        readonly autoincrement: 1;
        readonly computed: 0;
        readonly datatype: "int";
        readonly fk_column: null;
        readonly fk_table: null;
        readonly name: "id";
        readonly nullable: 0;
        readonly pk: 1;
        readonly position: 1;
    }, {
        readonly autoincrement: 0;
        readonly computed: 0;
        readonly datatype: "timestamp";
        readonly fk_column: null;
        readonly fk_table: null;
        readonly name: "created_at";
        readonly nullable: 1;
        readonly pk: 0;
        readonly position: 2;
    }, {
        readonly autoincrement: 0;
        readonly computed: 0;
        readonly datatype: "enum('admin','maintainer','member')";
        readonly fk_column: null;
        readonly fk_table: null;
        readonly name: "role";
        readonly nullable: 0;
        readonly pk: 0;
        readonly position: 3;
    }, {
        readonly autoincrement: 0;
        readonly computed: 0;
        readonly datatype: "int";
        readonly fk_column: "id";
        readonly fk_table: "animals";
        readonly name: "animal_id";
        readonly nullable: 1;
        readonly pk: 0;
        readonly position: 4;
    }];
    readonly name: "users";
    readonly schema: "studio";
    readonly type: "BASE TABLE";
}];
declare function getTimezoneQuery(requirements?: Omit<BuilderRequirements, "Adapter" | "QueryCompiler">): Query<{
    timezone: string;
}>;
declare function mockTimezoneQuery(): [{
    readonly timezone: "UTC";
}];

declare function getCancelQuery(threadId: unknown): Query<unknown>;

export { type MySQLAdapterRequirements, createMySQLAdapter, getCancelQuery, getDeleteQuery, getInsertQuery, getInsertRefetchQuery, getSelectQuery, getTablesQuery, getTimezoneQuery, getUpdateQuery, getUpdateRefetchQuery, mockIntrospect, mockSelectQuery, mockTablesQuery, mockTimezoneQuery };
