package com.fy.tool.toolmaker.entity;

import java.io.Serializable;
import java.util.Date;

import javax.persistence.Column;
import javax.persistence.Id;
import javax.persistence.Table;

import com.fy.toolhelper.db.IBaseDao;

/**
 * 示例实体
 * 1.这些注解标记不具备自动建表功能, 主要为数据库查询结果映射为实体对象实例提供映射信息, 所以请手工建表.
 * 2.同时像@ManyToOne这种外键的注解也没有对应实现, 如果需要在实体中拓展出另一个关联实体, 需要配合{@link IBaseDao #extend(java.sql.Connection, java.util.List, String[], IBaseDao[])}进行处理.
 * 3.建议将实体作为接口结果直接返回, 不需要中间DTO和VO, 如果工具不复杂的话.
 */
@Table(name = "register_tool")
public class ToolMakerEntity implements Serializable {
    private static final long serialVersionUID = -6061972293805592493L;

    /*
     * 所有字段都使用类类型, 不要使用基本类型, 这样更能满足可以为null这种语义的情况
     * 数据库注解只能放在字段上, 请注意, 放在GETTER方法上的还没有支持
     */
    /**
     * 主键
     */
    @Id
    @Column(name = "id")
    private Long/* 支持Integer, String, Long */ id;

    /**
     * 普通字段
     */
    @Column(name = "tool_name")
    private String toolName;

    @Column(name = "create_time")
    private Date createTime;

    @Column(name = "view_source")
    private Integer viewSource;

    @Column(name = "is_deploy")
    private Integer isDeploy;

    @Column(name = "fields")
    private String fields;

    @Column(name = "tool_description")
    private String toolDescription;

    @Column(name = "formula_fields")
    private String formulaFields;

    @Column(name = "data_table_name")
    private String dataTableName;

    @Column(name = "tool_other_name")
    private String toolOtherName;

    @Column(name = "parent_tool_name")
    private String parentToolName;

    public String getParentToolName() {
        return parentToolName;
    }

    public void setParentToolName(String parentToolName) {
        this.parentToolName = parentToolName;
    }

    public String getToolOtherName() {
        return toolOtherName;
    }

    public void setToolOtherName(String toolOtherName) {
        this.toolOtherName = toolOtherName;
    }

    public String getDataTableName() {
        return dataTableName;
    }

    public void setDataTableName(String dataTableName) {
        this.dataTableName = dataTableName;
    }

    public String getFormulaFields() {
        return formulaFields;
    }

    public void setFormulaFields(String formulaFields) {
        this.formulaFields = formulaFields;
    }

    public String getToolName() {
        return toolName;
    }

    public void setToolName(String toolName) {
        this.toolName = toolName;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public Integer getViewSource() {
        return viewSource;
    }

    public void setViewSource(Integer viewSource) {
        this.viewSource = viewSource;
    }

    public Integer getIsDeploy() {
        return isDeploy;
    }

    public void setIsDeploy(Integer isDeploy) {
        this.isDeploy = isDeploy;
    }

    public String getFields() {
        return fields;
    }

    public void setFields(String fields) {
        this.fields = fields;
    }

    public String getToolDescription() {
        return toolDescription;
    }

    public void setToolDescription(String toolDescription) {
        this.toolDescription = toolDescription;
    }

    public ToolMakerEntity getToolMakerEntity() {
        return toolMakerEntity;
    }

    public void setToolMakerEntity(ToolMakerEntity toolMakerEntity) {
        this.toolMakerEntity = toolMakerEntity;
    }

    /**
     * 拓展的实体对象, 不属于表结构的一部分, 添加数据库注解无效.
     * 如果是对应着某个外键字段, 则仍然需要在上面定义好该外键字段的实体属性并配置好注解.
     * 调用{@link IBaseDao #extend(java.sql.Connection, java.util.List, String[], IBaseDao[])}进行基础的查询和填充该属性实例.
     * 或者开发者可以自己定义和实现填充实例.
     * 只能拓展一层, 多层需要开发者多次调用拓展实现.
     */
    private ToolMakerEntity toolMakerEntity;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }


}
