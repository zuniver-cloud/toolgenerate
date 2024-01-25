package ${package_name}.entity;

import lombok.Data;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Table;

import java.sql.Date;
import java.sql.Time;

/**
* ${tool_class_name} 实体类
*/
@Data
@Table(name = "${table_name}")
public class ${entityName} implements Serializable {
<#--必须指定一个主键-->
<#if isFromDatabase>
    @Id
</#if>
<#--生成 Field-->
<#if columns??>
    <#list columns as c>
        <#--注释-->
        <#if c.comment?? && c.comment != ''>
    /**
    * ${c.comment!}
    */
        </#if>
        <#if c.type == 'INT' || c.type == 'SMALLINT' || c.type == 'TINYINT'>
            <#if c.name == 'id'>
    @Id
    @Column(name = "${c.name}")
    private Long ${c.changedName?uncap_first};
            <#else>
    @Column(name = "${c.name}")
    private int ${c.changedName?uncap_first};
            </#if>
        <#elseif c.type == 'BIGINT' || c.type == 'NUMERIC' || c.type == 'DECIMAL'>
            <#if c.name == 'id'>
    @Id
    @Column(name = "${c.name}")
    private Long ${c.changedName?uncap_first};
            <#else>
    @Column(name = "${c.name}")
    private Long ${c.changedName?uncap_first};
            </#if>
        <#elseif c.type == 'VARCHAR' || c.type == 'TEXT'>
    @Column(name = "${c.name}")
    private String ${c.changedName?uncap_first};
        <#elseif c.type == 'TIMESTAMP' || c.type == 'DATE'>
    @Column(name = "${c.name}")
    private Date ${c.changedName?uncap_first};
        <#elseif c.type == 'TIME'>
    @Column(name = "${c.name}")
    private Time ${c.changedName?uncap_first};
        <#elseif c.type == 'BIT'>
    @Column(name = "${c.name}")
    private Boolean ${c.changedName?uncap_first};
        <#else>
    @Column(name = "${c.name}")
    private String ${c.changedName?uncap_first};
        </#if>

    </#list>
</#if>
}