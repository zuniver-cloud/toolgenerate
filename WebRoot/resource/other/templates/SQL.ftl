
<#if isFromDatabase>
    //生成数据库视图
    <#list tables as t>
        DROP VIEW IF EXISTS `${t.name}`;
        CREATE VIEW ${t.name} AS
        SELECT
        <#list t.columns as c>
        ${c.parentTable!}.${c.name!} <#if c_has_next>,</#if>
        </#list>
        <#if connectCondition?exists>
        FROM ${connectCondition}
        <#else>
        FROM ${t.columns[0].parentTable}
        </#if>
    </#list>
<#else>
    //生成新表
    <#list tables as t>

        DROP TABLE IF EXISTS `${t.name}`;
        CREATE TABLE `${t.name}` (
        <#if t.columns??>
            <#list t.columns as c>
                <#if c.name == 'id'>
                        id int(11) NOT NULL AUTO_INCREMENT,
                <#else>
                    <#if c.type == 'varchar'>
                        ${c.name!} varchar(250) COMMENT '${c.comment!}',
                    <#else>
                        ${c.name!} ${c.type!} COMMENT '${c.comment!}',
                    </#if>
                <#--       `${c.name!}` ${c.type!} COMMENT '${c.comment!}',-->
                </#if>
            </#list>
        </#if>
        PRIMARY KEY (`id`)
        ) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8  COMMENT = '${t.nameChinese}';

    </#list>
</#if>


