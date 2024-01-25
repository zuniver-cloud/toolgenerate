#工具名称
${tool_name}

#工具创建者
${company!}

#工具创建日期
${datetime!}

#工具描述信息
${tool_description!}

<#list tables as t>
#工具使用的数据库信息

##数据表名
${t.name}

##数据表字段--字段类型--数据表字段别名
    <#if t.columns??>
        <#list t.columns as c>
${c.name!}--${c.type!}--${c.showName!}
        </#list>
    </#if>
</#list>