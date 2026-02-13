import { d as AdapterRequirements, A as Adapter, T as Table, F as FilterOperator, Q as Query, g as AdapterInsertDetails, B as BuilderRequirements, e as AdapterQueryDetails, h as AdapterUpdateDetails, f as AdapterDeleteDetails } from '../../index-BhPjNuvP.cjs';
import 'kysely';

type PostgresAdapterRequirements = AdapterRequirements;
declare function createPostgresAdapter(requirements: PostgresAdapterRequirements): Adapter;
/**
 * For testing purposes.
 */
declare function mockIntrospect(): {
    schemas: { [K in "zoo" | "public"]: {
        name: K;
        tables: { [T in "animals" | "users" | "composite_pk"]: Table; };
    }; };
    timezone: "UTC";
    filterOperators: FilterOperator[];
    query: Query;
};

/**
 * Inserts one or more rows into a table and returns the inserted rows along with their `ctid`.
 */
declare function getInsertQuery(details: AdapterInsertDetails, requirements?: Omit<BuilderRequirements, "Adapter" | "QueryCompiler">): Query<{
    [x: string]: unknown;
} & {
    __ps_inserted_at__: `${bigint}`;
}>;
/**
 * Returns a query that selects all columns from a table, along with an unbound row count as `__ps_count__`.
 */
declare function getSelectQuery(details: AdapterQueryDetails, requirements?: Omit<BuilderRequirements, "Adapter" | "QueryCompiler">): Query<{
    [x: string]: unknown;
    __ps_count__: `${bigint}`;
}>;
/**
 * For testing purposes.
 */
declare function mockSelectQuery(): [{
    readonly created_at: Date;
    readonly deleted_at: null;
    readonly id: 1;
    readonly name: "John Doe";
    readonly __ps_count__: "2";
    readonly role: "admin";
    readonly name_role: "Jonn Doe - admin";
}, {
    readonly created_at: Date;
    readonly deleted_at: null;
    readonly id: 2;
    readonly name: "Jane Doe";
    readonly __ps_count__: "2";
    readonly role: "poweruser";
    readonly name_role: "Jane Doe - poweruser";
}];
/**
 * Returns a query that updates a given row in a table with given changes.
 */
declare function getUpdateQuery(details: AdapterUpdateDetails, requirements?: Omit<BuilderRequirements, "Adapter" | "QueryCompiler">): Query<{
    [x: string]: unknown;
    __ps_updated_at__: `${bigint}`;
}>;
/**
 * Returns a query that deletes a given set of rows.
 */
declare function getDeleteQuery(details: AdapterDeleteDetails, requirements?: Omit<BuilderRequirements, "Adapter" | "QueryCompiler">): Query<{
    [x: string]: unknown;
    __ps_deleted_at__: `${bigint}`;
}>;

/**
 * Returns a query that returns metadata for all user-defined tables and views in the database.
 */
declare function getTablesQuery(requirements?: Omit<BuilderRequirements, "Adapter" | "QueryCompiler">): Query<{
    schema: string;
    name: string;
    columns: {
        name: string;
        datatype: string;
        datatype_schema: string;
        fk_schema: string | null;
        fk_table: string | null;
        fk_column: string | null;
        pk: boolean;
        computed: boolean;
        nullable: boolean;
        options: string[];
    }[];
}>;
/**
 * For testing purposes.
 */
declare function mockTablesQuery(): [{
    readonly schema: "zoo";
    readonly name: "animals";
    readonly columns: [{
        readonly name: "id";
        readonly datatype: "int4";
        readonly datatype_schema: "pg_catalog";
        readonly pk: true;
        readonly computed: false;
        readonly options: [];
        readonly nullable: false;
        readonly fk_schema: null;
        readonly fk_table: null;
        readonly fk_column: null;
    }, {
        readonly name: "name";
        readonly datatype: "text";
        readonly datatype_schema: "pg_catalog";
        readonly pk: false;
        readonly computed: false;
        readonly options: [];
        readonly nullable: true;
        readonly fk_schema: null;
        readonly fk_table: null;
        readonly fk_column: null;
    }];
}, {
    readonly schema: "public";
    readonly name: "users";
    readonly columns: [{
        readonly name: "id";
        readonly datatype: "int4";
        readonly datatype_schema: "pg_catalog";
        readonly pk: true;
        readonly computed: false;
        readonly options: [];
        readonly nullable: false;
        readonly fk_schema: null;
        readonly fk_table: null;
        readonly fk_column: null;
    }, {
        readonly name: "created_at";
        readonly datatype: "timestamp";
        readonly datatype_schema: "pg_catalog";
        readonly pk: false;
        readonly computed: false;
        readonly options: [];
        readonly nullable: true;
        readonly fk_schema: null;
        readonly fk_table: null;
        readonly fk_column: null;
    }, {
        readonly name: "deleted_at";
        readonly datatype: "timestamp";
        readonly datatype_schema: "pg_catalog";
        readonly pk: false;
        readonly computed: false;
        readonly options: [];
        readonly nullable: true;
        readonly fk_schema: null;
        readonly fk_table: null;
        readonly fk_column: null;
    }, {
        readonly name: "role";
        readonly datatype: "varchar";
        readonly datatype_schema: "pg_catalog";
        readonly pk: false;
        readonly computed: false;
        readonly options: [];
        readonly nullable: true;
        readonly fk_schema: null;
        readonly fk_table: null;
        readonly fk_column: null;
    }, {
        readonly name: "name";
        readonly datatype: "varchar";
        readonly datatype_schema: "pg_catalog";
        readonly pk: false;
        readonly computed: false;
        readonly options: [];
        readonly nullable: true;
        readonly fk_schema: null;
        readonly fk_table: null;
        readonly fk_column: null;
    }, {
        readonly name: "name_role";
        readonly datatype: "text";
        readonly datatype_schema: "pg_catalog";
        readonly pk: false;
        readonly computed: true;
        readonly options: [];
        readonly nullable: false;
        readonly fk_schema: null;
        readonly fk_table: null;
        readonly fk_column: null;
    }];
}, {
    readonly schema: "public";
    readonly name: "composite_pk";
    readonly columns: [{
        readonly name: "id";
        readonly datatype: "uuid";
        readonly datatype_schema: "pg_catalog";
        readonly pk: true;
        readonly computed: false;
        readonly options: [];
        readonly nullable: false;
        readonly fk_schema: null;
        readonly fk_table: null;
        readonly fk_column: null;
    }, {
        readonly name: "name";
        readonly datatype: "text";
        readonly datatype_schema: "pg_catalog";
        readonly pk: true;
        readonly computed: false;
        readonly options: [];
        readonly nullable: true;
        readonly fk_schema: null;
        readonly fk_table: null;
        readonly fk_column: null;
    }, {
        readonly name: "created_at";
        readonly datatype: "timestamp";
        readonly datatype_schema: "pg_catalog";
        readonly pk: false;
        readonly computed: false;
        readonly options: [];
        readonly nullable: true;
        readonly fk_schema: null;
        readonly fk_table: null;
        readonly fk_column: null;
    }];
}];
/**
 * Returns a query that returns the current timezone setting of the PostgreSQL database.
 */
declare function getTimezoneQuery(): Query<{
    timezone: string;
}>;
/**
 * For testing purposes.
 */
declare function mockTimezoneQuery(): [{
    readonly timezone: "UTC";
}];

declare function getPIDQuery(): Query<{
    pid: unknown;
}>;
declare function getCancelQuery(pid: {}): Query<unknown>;

export { type PostgresAdapterRequirements, createPostgresAdapter, getCancelQuery, getDeleteQuery, getInsertQuery, getPIDQuery, getSelectQuery, getTablesQuery, getTimezoneQuery, getUpdateQuery, mockIntrospect, mockSelectQuery, mockTablesQuery, mockTimezoneQuery };
