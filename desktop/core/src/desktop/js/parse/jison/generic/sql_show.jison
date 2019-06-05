// Licensed to Cloudera, Inc. under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  Cloudera, Inc. licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

DataDefinition
 : ShowStatement
 ;

DataDefinition_EDIT
 : ShowStatement_EDIT
 ;

ShowStatement
 : ShowColumnStatsStatement
 | ShowColumnsStatement
 | ShowCompactionsStatement
 | ShowConfStatement
 | ShowCreateTableStatement
 | ShowCurrentRolesStatement
 | ShowDatabasesStatement
 | ShowFilesStatement
 | ShowFunctionsStatement
 | ShowGrantStatement
 | ShowIndexStatement
 | ShowLocksStatement
 | ShowPartitionsStatement
 | ShowRoleStatement
 | ShowRolesStatement
 | ShowTableStatement
 | ShowTblPropertiesStatement
 | ShowTransactionsStatement
 | ShowViewsStatement
 ;

AnyShow
 : 'SHOW'
 | '<hive>SHOW'
 ;

ShowStatement_EDIT
 : AnyShow 'CURSOR'
   {
     if (parser.isHive()) {
       parser.suggestKeywords(['COLUMNS', 'COMPACTIONS', 'CONF', 'CREATE TABLE', 'CURRENT ROLES', 'DATABASES', 'FORMATTED', 'FUNCTIONS', 'GRANT', 'INDEX', 'INDEXES', 'LOCKS', 'PARTITIONS', 'PRINCIPALS', 'ROLE GRANT', 'ROLES', 'SCHEMAS', 'TABLE EXTENDED', 'TABLES', 'TBLPROPERTIES', 'TRANSACTIONS', 'VIEWS']);
     } else if (parser.isImpala()) {
       parser.suggestKeywords(['AGGREGATE FUNCTIONS', 'ANALYTIC FUNCTIONS', 'COLUMN STATS', 'CREATE TABLE', 'CURRENT ROLES', 'CREATE VIEW', 'DATABASES', 'FILES IN', 'FUNCTIONS', 'GRANT ROLE', 'GRANT USER', 'PARTITIONS', 'RANGE PARTITIONS', 'ROLE GRANT GROUP', 'ROLES', 'SCHEMAS', 'TABLE STATS', 'TABLES']);
     } else {
       parser.suggestKeywords(['COLUMNS', 'DATABASES', 'TABLES']);
     }
   }
 | AnyShow 'CURSOR' RegularOrBackTickedSchemaQualifiedName
   {
     // ROLES is considered a non-reserved keywords so we can't match it in ShowCurrentRolesStatement_EDIT
     if (!parser.isImpala() && $3.identifierChain && $3.identifierChain.length === 1 && $3.identifierChain[0].name.toLowerCase() === 'roles') {
       parser.suggestKeywords(['CURRENT']);
       parser.yy.locations.pop();
     } else {
       parser.addTablePrimary($3);
       if (parser.isImpala()) {
         parser.suggestKeywords(['COLUMN STATS', 'CREATE TABLE', 'CREATE VIEW', 'FILES IN', 'PARTITIONS', 'RANGE PARTITIONS', 'TABLE STATS']);
       }
     }
   }
 | AnyShow 'CURSOR' LIKE SingleQuotedValue
   {
     if (parser.isImpala()) {
       parser.suggestKeywords(['AGGREGATE FUNCTIONS', 'ANALYTIC FUNCTIONS', 'DATABASES', 'FUNCTIONS', 'SCHEMAS', 'TABLES']);
     } else if (parser.isHive()) {
       parser.suggestKeywords(['DATABASES', 'SCHEMAS', 'TABLE EXTENDED']);
     }
   }
 | ShowColumnStatsStatement_EDIT
 | ShowColumnsStatement_EDIT
 | ShowCreateTableStatement_EDIT
 | ShowCurrentRolesStatement_EDIT
 | ShowDatabasesStatement_EDIT
 | ShowFilesStatement_EDIT
 | ShowFunctionsStatement_EDIT
 | ShowGrantStatement_EDIT
 | ShowIndexStatement_EDIT
 | ShowLocksStatement_EDIT
 | ShowPartitionsStatement_EDIT
 | ShowRoleStatement_EDIT
 | ShowTableStatement_EDIT
 | ShowTblPropertiesStatement_EDIT
 | ShowViewsStatement_EDIT
 ;

ShowColumnStatsStatement
 : AnyShow '<impala>COLUMN' '<impala>STATS' RegularOrBackTickedSchemaQualifiedName
   {
     parser.addTablePrimary($4);
   }
 ;

ShowColumnStatsStatement_EDIT
 : AnyShow '<impala>COLUMN' 'CURSOR'
   {
     parser.suggestKeywords(['STATS']);
   }
 | AnyShow '<impala>COLUMN' '<impala>STATS' 'CURSOR'
   {
     parser.suggestTables();
     parser.suggestDatabases({
       appendDot: true
     });
   }
 | AnyShow '<impala>COLUMN' '<impala>STATS' RegularOrBackTickedSchemaQualifiedName_EDIT
 ;

ShowColumnsStatement
 : AnyShow '<hive>COLUMNS' FromOrIn RegularOrBacktickedIdentifier
 | AnyShow '<hive>COLUMNS' FromOrIn RegularOrBacktickedIdentifier FromOrIn RegularOrBacktickedIdentifier
 ;

ShowColumnsStatement_EDIT
 : AnyShow '<hive>COLUMNS' 'CURSOR'
   {
     parser.suggestKeywords(['FROM', 'IN']);
   }
 | AnyShow '<hive>COLUMNS' 'CURSOR' RegularOrBacktickedIdentifier
   {
     parser.suggestKeywords(['FROM', 'IN']);
   }
 | AnyShow '<hive>COLUMNS' FromOrIn 'CURSOR'
   {
     parser.suggestTables();
   }
 | AnyShow '<hive>COLUMNS' FromOrIn 'CURSOR' FromOrIn
   {
     parser.suggestTables();
   }
 | AnyShow '<hive>COLUMNS' FromOrIn 'CURSOR' FromOrIn RegularOrBacktickedIdentifier
   {
     parser.suggestTables();
   }
 | AnyShow '<hive>COLUMNS' FromOrIn RegularOrBacktickedIdentifier 'CURSOR'
   {
     parser.suggestKeywords(['FROM', 'IN']);
   }
 | AnyShow '<hive>COLUMNS' FromOrIn RegularOrBacktickedIdentifier 'CURSOR' RegularOrBacktickedIdentifier
   {
     parser.suggestKeywords(['FROM', 'IN']);
   }
 | AnyShow '<hive>COLUMNS' FromOrIn RegularOrBacktickedIdentifier FromOrIn 'CURSOR'
   {
     parser.suggestDatabases();
   }
 ;

ShowCompactionsStatement
 : AnyShow '<hive>COMPACTIONS'
 ;

ShowConfStatement
 : AnyShow '<hive>CONF' ConfigurationName
 ;

ShowCreateTableStatement
 ;

ShowCreateTableStatement_EDIT
 ;

AnyTableOrView
 : 'TABLE'
 | 'VIEW'   --> { isView: true }
 ;

ShowCurrentRolesStatement
 : AnyShow '<hive>CURRENT' '<hive>ROLES'
 | AnyShow '<impala>CURRENT' '<impala>ROLES'
 ;

ShowCurrentRolesStatement_EDIT
 : AnyShow '<hive>CURRENT' 'CURSOR'
   {
     parser.suggestKeywords([ 'ROLES' ]);
   }
 | AnyShow '<impala>CURRENT' 'CURSOR'
   {
     parser.suggestKeywords([ 'ROLES' ]);
   }
 | AnyShow 'CURSOR' '<impala>ROLES'
   {
     parser.suggestKeywords([ 'CURRENT' ]);
   }
 ;

ShowDatabasesStatement
 ;

ShowDatabasesStatement_EDIT
 ;

ShowFilesStatement
 : AnyShow '<impala>FILES' 'IN' RegularOrBackTickedSchemaQualifiedName OptionalPartitionSpec
   {
     parser.addTablePrimary($4);
   }
 ;

ShowFilesStatement_EDIT
 : AnyShow '<impala>FILES' 'CURSOR'
   {
     parser.suggestKeywords(['IN']);
   }
 | AnyShow '<impala>FILES' 'IN' 'CURSOR'
   {
     parser.suggestTables();
     parser.suggestDatabases({
       appendDot: true
     });
   }
 | AnyShow '<impala>FILES' 'IN' RegularOrBackTickedSchemaQualifiedName_EDIT OptionalPartitionSpec
 | AnyShow '<impala>FILES' 'IN' RegularOrBackTickedSchemaQualifiedName OptionalPartitionSpec 'CURSOR'
   {
     parser.addTablePrimary($4);
     if (!$5) {
       parser.suggestKeywords(['PARTITION']);
     }
   }
 | AnyShow '<impala>FILES' 'IN' RegularOrBackTickedSchemaQualifiedName OptionalPartitionSpec_EDIT
 | AnyShow '<impala>FILES' 'CURSOR' RegularOrBackTickedSchemaQualifiedName OptionalPartitionSpec
   {
     parser.addTablePrimary($4);
     parser.suggestKeywords(['IN']);
   }
 ;

ShowFunctionsStatement
 : AnyShow '<hive>FUNCTIONS'
 | AnyShow '<hive>FUNCTIONS' DoubleQuotedValue
 | AnyShow OptionalAggregateOrAnalytic '<impala>FUNCTIONS' OptionalInDatabase
 | AnyShow OptionalAggregateOrAnalytic '<impala>FUNCTIONS' OptionalInDatabase 'LIKE' QuotedValue
 ;

ShowFunctionsStatement_EDIT
 | AnyShow 'CURSOR' '<impala>FUNCTIONS' OptionalInDatabase
   {
     parser.suggestKeywords(['AGGREGATE', 'ANALYTICAL']);
   }
 | AnyShow OptionalAggregateOrAnalytic '<impala>FUNCTIONS' OptionalInDatabase 'CURSOR'
   {
     if (!$4) {
       parser.suggestKeywords(['IN', 'LIKE']);
     } else {
       parser.suggestKeywords(['LIKE']);
     }
   }
 | AnyShow 'CURSOR' '<impala>FUNCTIONS' OptionalInDatabase 'LIKE' QuotedValue
   {
     parser.suggestKeywords(['AGGREGATE', 'ANALYTICAL']);
   }
 | AnyShow OptionalAggregateOrAnalytic '<impala>FUNCTIONS' OptionalInDatabase 'CURSOR' QuotedValue
   {
     if (!$4) {
       parser.suggestKeywords([{ value: 'IN', weight: 2 }, { value: 'LIKE', weight: 1 }]);
     } else {
       parser.suggestKeywords(['LIKE']);
     }
   }
 ;

ShowGrantStatement
 : AnyShow '<hive>GRANT' OptionalPrincipalName
 | AnyShow '<hive>GRANT' OptionalPrincipalName 'ON' '<hive>ALL'
 | AnyShow '<hive>GRANT' OptionalPrincipalName 'ON' SchemaQualifiedTableIdentifier
 | AnyShow '<hive>GRANT' OptionalPrincipalName 'ON' 'TABLE' SchemaQualifiedTableIdentifier
 ;

ShowGrantStatement_EDIT
 : AnyShow '<hive>GRANT' OptionalPrincipalName_EDIT
   {
     parser.suggestKeywords(['ON']);
   }
 | AnyShow '<hive>GRANT' OptionalPrincipalName_EDIT 'ON' '<hive>ALL'
 | AnyShow '<hive>GRANT' OptionalPrincipalName 'ON' 'CURSOR'
   {
     parser.suggestKeywords(['ALL', 'TABLE']);
     parser.suggestTables();
   }
 | AnyShow '<hive>GRANT' OptionalPrincipalName 'ON' SchemaQualifiedTableIdentifier_EDIT
 | AnyShow  '<hive>GRANT' OptionalPrincipalName 'ON' 'TABLE' 'CURSOR'
   {
     parser.suggestTables();
   }
 | AnyShow '<hive>GRANT' OptionalPrincipalName 'ON' 'CURSOR' SchemaQualifiedTableIdentifier
   {
     parser.suggestKeywords(['TABLE']);
   }
 | AnyShow '<hive>GRANT' OptionalPrincipalName 'ON' 'CURSOR' SchemaQualifiedTableIdentifier_EDIT
 | AnyShow '<impala>GRANT' 'CURSOR'
   {
     parser.suggestKeywords(['ROLE', 'USER']);
   }
 ;

OptionalPrincipalName
 :
 | RegularIdentifier
 ;

OptionalPrincipalName_EDIT
 : 'CURSOR'
 | RegularIdentifier 'CURSOR'
 ;

ShowIndexStatement
 : AnyShow OptionallyFormattedIndex 'ON' RegularOrBacktickedIdentifier
 | AnyShow OptionallyFormattedIndex 'ON' RegularOrBacktickedIdentifier FromOrIn RegularOrBacktickedIdentifier
 ;

ShowIndexStatement_EDIT
 : AnyShow OptionallyFormattedIndex
 | AnyShow OptionallyFormattedIndex_EDIT
 | AnyShow OptionallyFormattedIndex_EDIT 'ON' RegularOrBacktickedIdentifier
 | AnyShow OptionallyFormattedIndex_EDIT 'ON' RegularOrBacktickedIdentifier FromOrIn RegularOrBacktickedIdentifier
 | AnyShow OptionallyFormattedIndex 'CURSOR'
   {
     parser.suggestKeywords(['ON']);
   }
 | AnyShow OptionallyFormattedIndex 'ON' 'CURSOR'
   {
     parser.suggestTables();
   }
 | AnyShow OptionallyFormattedIndex 'CURSOR' RegularOrBacktickedIdentifier
   {
     parser.suggestKeywords(['ON']);
   }
 | AnyShow OptionallyFormattedIndex 'ON' RegularOrBacktickedIdentifier 'CURSOR'
   {
     parser.suggestKeywords(['FROM', 'IN']);
   }
 | AnyShow OptionallyFormattedIndex 'ON' RegularOrBacktickedIdentifier 'CURSOR' RegularOrBacktickedIdentifier
   {
     parser.suggestKeywords(['FROM', 'IN']);
   }
 | AnyShow OptionallyFormattedIndex 'ON' RegularOrBacktickedIdentifier FromOrIn 'CURSOR'
   {
     parser.suggestDatabases();
   }
 | AnyShow OptionallyFormattedIndex 'ON' 'CURSOR' FromOrIn RegularOrBacktickedIdentifier
   {
     parser.suggestTables({identifierChain: [{name: $6}]});
   }
 ;

ShowLocksStatement
 : AnyShow '<hive>LOCKS' RegularOrBackTickedSchemaQualifiedName
   {
     parser.addTablePrimary($3);
   }
 | AnyShow '<hive>LOCKS' RegularOrBackTickedSchemaQualifiedName '<hive>EXTENDED'
   {
     parser.addTablePrimary($3);
   }
 | AnyShow '<hive>LOCKS' RegularOrBackTickedSchemaQualifiedName PartitionSpec
   {
     parser.addTablePrimary($3);
   }
 | AnyShow '<hive>LOCKS' RegularOrBackTickedSchemaQualifiedName PartitionSpec '<hive>EXTENDED'
   {
     parser.addTablePrimary($3);
   }
 | AnyShow '<hive>LOCKS' DatabaseOrSchema RegularOrBacktickedIdentifier
 ;

ShowLocksStatement_EDIT
 : AnyShow '<hive>LOCKS' 'CURSOR'
   {
     parser.suggestTables();
     parser.suggestDatabases({
       appendDot: true
     });
     parser.suggestKeywords(['DATABASE', 'SCHEMA']);
   }
 | AnyShow '<hive>LOCKS' RegularOrBackTickedSchemaQualifiedName_EDIT
 | AnyShow '<hive>LOCKS' RegularOrBackTickedSchemaQualifiedName 'CURSOR'
    {
      parser.addTablePrimary($3);
      parser.suggestKeywords(['EXTENDED', 'PARTITION']);
    }
 | AnyShow '<hive>LOCKS' RegularOrBackTickedSchemaQualifiedName_EDIT '<hive>EXTENDED'
 | AnyShow '<hive>LOCKS' RegularOrBackTickedSchemaQualifiedName_EDIT PartitionSpec
 | AnyShow '<hive>LOCKS' RegularOrBackTickedSchemaQualifiedName PartitionSpec 'CURSOR'
   {
     parser.addTablePrimary($3);
     parser.suggestKeywords(['EXTENDED']);
   }
 | AnyShow '<hive>LOCKS' RegularOrBackTickedSchemaQualifiedName_EDIT PartitionSpec '<hive>EXTENDED'
 | AnyShow '<hive>LOCKS' DatabaseOrSchema 'CURSOR'
   {
     parser.suggestDatabases();
   }
 ;

ShowPartitionsStatement
 : AnyShow '<hive>PARTITIONS' RegularOrBackTickedSchemaQualifiedName
   {
     parser.addTablePrimary($3);
   }
 | AnyShow '<hive>PARTITIONS' RegularOrBackTickedSchemaQualifiedName PartitionSpec
   {
     parser.addTablePrimary($3);
   }
 | AnyShow '<impala>PARTITIONS' RegularOrBackTickedSchemaQualifiedName
   {
     parser.addTablePrimary($3);
   }
 | AnyShow '<impala>RANGE' '<impala>PARTITIONS' RegularOrBackTickedSchemaQualifiedName
   {
     parser.addTablePrimary($3);
   }
 ;

ShowPartitionsStatement_EDIT
 : AnyShow '<hive>PARTITIONS' 'CURSOR'
   {
     parser.suggestTables();
     parser.suggestDatabases({
       appendDot: true
     });
   }
 | AnyShow '<hive>PARTITIONS' RegularOrBackTickedSchemaQualifiedName_EDIT
 | AnyShow '<hive>PARTITIONS' RegularOrBackTickedSchemaQualifiedName 'CURSOR'
   {
     parser.addTablePrimary($3);
     parser.suggestKeywords(['PARTITION']);
   }
 | AnyShow '<hive>PARTITIONS' RegularOrBackTickedSchemaQualifiedName_EDIT PartitionSpec
 | AnyShow '<impala>PARTITIONS' 'CURSOR'
   {
     parser.suggestTables();
     parser.suggestDatabases({
       appendDot: true
     });
   }
 | AnyShow '<impala>PARTITIONS' RegularOrBackTickedSchemaQualifiedName_EDIT
 | AnyShow '<impala>RANGE' '<impala>PARTITIONS' 'CURSOR'
   {
     parser.suggestTables();
     parser.suggestDatabases({
       appendDot: true
     });
   }
 | AnyShow '<impala>RANGE' '<impala>PARTITIONS' RegularOrBackTickedSchemaQualifiedName_EDIT
 ;

ShowRoleStatement
 ;

ShowRoleStatement_EDIT
 ;

ShowRolesStatement
 : AnyShow '<impala>ROLES'
 | AnyShow '<hive>ROLES'
 ;

ShowTableStatement
 : AnyShow '<hive>TABLE' '<hive>EXTENDED' OptionalFromDatabase 'LIKE' SingleQuotedValue
 | AnyShow '<hive>TABLE' '<hive>EXTENDED' OptionalFromDatabase 'LIKE' SingleQuotedValue PartitionSpec
 ;

ShowTableStatement_EDIT
 : AnyShow '<hive>TABLE' 'CURSOR'
   {
     parser.suggestKeywords(['EXTENDED']);
   }
 | AnyShow '<hive>TABLE' '<hive>EXTENDED' OptionalFromDatabase
 | AnyShow '<hive>TABLE' '<hive>EXTENDED' OptionalFromDatabase_EDIT
 | AnyShow '<hive>TABLE' '<hive>EXTENDED' OptionalFromDatabase 'CURSOR'
    {
      if ($4) {
        parser.suggestKeywords(['LIKE']);
      } else {
        parser.suggestKeywords(['FROM', 'IN', 'LIKE']);
      }
    }
 | AnyShow '<hive>TABLE' '<hive>EXTENDED' OptionalFromDatabase_EDIT 'LIKE' SingleQuotedValue
 | AnyShow '<hive>TABLE' 'CURSOR' OptionalFromDatabase 'LIKE' SingleQuotedValue
    {
      if (parser.isHive()) {
        parser.suggestKeywords(['EXTENDED']);
      }
    }
 | AnyShow '<hive>TABLE' '<hive>EXTENDED' OptionalFromDatabase 'CURSOR' SingleQuotedValue
    {
      parser.suggestKeywords(['LIKE']);
    }
 | AnyShow '<hive>TABLE' '<hive>EXTENDED' OptionalFromDatabase 'LIKE' SingleQuotedValue 'CURSOR'
    {
      parser.suggestKeywords(['PARTITION']);
    }
 | AnyShow '<hive>TABLE' '<hive>EXTENDED' OptionalFromDatabase_EDIT 'LIKE' SingleQuotedValue PartitionSpec
 | AnyShow '<hive>TABLE' 'CURSOR' OptionalFromDatabase 'LIKE' SingleQuotedValue PartitionSpec
   {
     parser.suggestKeywords(['EXTENDED']);
   }
 | AnyShow '<hive>TABLE' '<hive>EXTENDED' OptionalFromDatabase 'CURSOR' SingleQuotedValue PartitionSpec
   {
     parser.suggestKeywords(['LIKE']);
   }
 | AnyShow '<hive>TABLE' '<hive>EXTENDED' OptionalFromDatabase 'LIKE' SingleQuotedValue 'CURSOR' PartitionSpecList
   {
     parser.suggestKeywords(['PARTITION']);
   }
 | AnyShow '<impala>TABLE' 'CURSOR'
   {
     parser.suggestKeywords(['STATS']);
   }
 | AnyShow '<impala>TABLE' '<impala>STATS' 'CURSOR'
   {
     parser.suggestTables();
     parser.suggestDatabases({
       appendDot: true
     });
   }
 | AnyShow '<impala>TABLE' '<impala>STATS' RegularOrBackTickedSchemaQualifiedName
    {
      parser.addTablePrimary($4);
    }
 | AnyShow '<impala>TABLE' '<impala>STATS' RegularOrBackTickedSchemaQualifiedName_EDIT
 ;

ShowTblPropertiesStatement
 : AnyShow '<hive>TBLPROPERTIES' RegularOrBackTickedSchemaQualifiedName
   {
     parser.addTablePrimary($3);
   }
 | AnyShow '<hive>TBLPROPERTIES' RegularOrBackTickedSchemaQualifiedName '(' QuotedValue ')'
   {
     parser.addTablePrimary($3);
   }
 ;

ShowTblPropertiesStatement_EDIT
 : AnyShow '<hive>TBLPROPERTIES' RegularOrBackTickedSchemaQualifiedName_EDIT
 | AnyShow '<hive>TBLPROPERTIES' 'CURSOR'
   {
     parser.suggestTables();
     parser.suggestDatabases({ prependDot: true });
   }
 ;

ShowTransactionsStatement
 : AnyShow '<hive>TRANSACTIONS'
 ;

ShowViewsStatement
 : AnyShow '<hive>VIEWS' OptionalInOrFromDatabase OptionalLike
 ;

ShowViewsStatement_EDIT
 : AnyShow '<hive>VIEWS' OptionalInOrFromDatabase OptionalLike 'CURSOR'
   {
     if (!$4 && !$3) {
       parser.suggestKeywords([{ value: 'IN', weight: 2 }, { value: 'FROM', weight: 2 }, { value: 'LIKE', weight: 1 }]);
     } else if (!$4) {
       parser.suggestKeywords(['LIKE']);
     }
   }
 | AnyShow '<hive>VIEWS' InOrFromDatabase_EDIT OptionalLike
 | AnyShow '<hive>VIEWS' OptionalInOrFromDatabase Like_EDIT
 ;

OptionalInOrFromDatabase
 :
 | 'IN' RegularOrBacktickedIdentifier
   {
     parser.addDatabaseLocation(@2, [ { name: $2 } ]);
   }
 | 'FROM' RegularOrBacktickedIdentifier
   {
     parser.addDatabaseLocation(@2, [ { name: $2 } ]);
   }
 ;

InOrFromDatabase_EDIT
 : 'IN' 'CURSOR'
   {
     parser.suggestDatabases();
   }
 | 'FROM' 'CURSOR'
   {
     parser.suggestDatabases();
   }
 ;

OptionalLike
 :
 | 'LIKE' SingleQuotedValue
 ;

Like_EDIT
 : 'LIKE' 'CURSOR'
 ;
