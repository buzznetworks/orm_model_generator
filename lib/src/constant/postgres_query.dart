import './constant.dart';

const kSelectSchemaNamesQuery = '''
SELECT DISTINCT table_schema
FROM information_schema.tables
WHERE table_schema NOT IN ('information_schema', 'pg_catalog')
ORDER BY table_schema;
''';

const kSelectTableNamesQuery = '''
SELECT table_name
FROM information_schema.tables
WHERE table_schema = '$kSchemaNameJoker'
ORDER BY table_name;
''';

const kSelectColumnsQuery = '''
SELECT column_name,
       udt_name,
       column_default,
       data_type,
       character_maximum_length,
       numeric_precision,
       numeric_scale,
       (SELECT COL_DESCRIPTION(CONCAT(c.table_schema, '.', '"', c.table_name, '"')::REGCLASS::OID,
                               c.ordinal_position))                      description,
       CASE WHEN is_nullable LIKE 'YES' THEN TRUE ELSE FALSE END         is_nullable,
       CASE WHEN column_default LIKE 'nextval%' THEN TRUE ELSE FALSE END is_identity,
       (SELECT COUNT(*) > 0
        FROM information_schema.table_constraints tc
                 INNER JOIN information_schema.constraint_column_usage cu
                            ON cu.constraint_name = tc.constraint_name
        WHERE tc.constraint_type = 'UNIQUE'
          AND tc.table_name = c.table_schema
          AND cu.column_name = c.column_name
          AND tc.table_schema = c.table_schema)                          is_unique,
       (SELECT STRING_AGG(enumlabel, '|')
        FROM pg_enum e
                 INNER JOIN pg_type t ON t.oid = e.enumtypid
                 INNER JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE n.nspname = c.table_schema
          AND t.typname = c.udt_name
       )                                                                 enum_values
FROM information_schema.columns c
WHERE c.table_schema = '$kSchemaNameJoker' 
AND c.table_name = '$kTableNameJoker'
ORDER BY c.ordinal_position;
''';

const _kRawSelectForeignKeysQuery = '''
SELECT DISTINCT con.relname                                      from_table,
                att.attnum                                       fk_partno,
                att2.attname                                     from_column,
                cl.relname                                       to_table,
                att.attname                                      to_column,
                delete_rule                                      on_delete,
                update_rule                                      on_update,
                CONCAT(con.conname, con.conrelid, con.confrelid) object_id
FROM (
         SELECT UNNEST(con1.conkey)  parent,
                UNNEST(con1.confkey) child,
                con1.confrelid,
                con1.conrelid,
                cl2.relname,
                con1.conname,
                nspname
         FROM pg_class cl2,
              pg_namespace ns,
              pg_constraint con1
         WHERE con1.contype = 'f'::"char"
           AND cl2.relnamespace = ns.oid
           AND con1.conrelid = cl2.oid
           AND nspname = '$kSchemaNameJoker'
     ) con,
     pg_attribute att,
     pg_class cl,
     pg_attribute att2,
     information_schema.referential_constraints rc
WHERE att.attrelid = con.confrelid
  AND att.attnum = con.child
  AND cl.oid = con.confrelid
  AND att2.attrelid = con.conrelid
  AND att2.attnum = con.parent
  AND rc.constraint_name = con.conname
  AND rc.constraint_schema = nspname
''';

const kSelectForeignKeysQuery = _kRawSelectForeignKeysQuery +
    '''
  AND (con.relname = '$kTableNameJoker'
    OR cl.relname = '$kTableNameJoker');
''';

const kSelectForeignKeyQuery = _kRawSelectForeignKeysQuery +
    '''
  AND con.relname = '$kTableNameJoker'
  AND att2.attname = '$kColumnJoker';
''';
