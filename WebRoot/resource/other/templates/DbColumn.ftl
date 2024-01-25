package ${package_name}.entity;

import lombok.Data;

/**
 * 数据库字段类
 */
@Data
public class DbColumn {
    /**
     * 字段名称
     **/
    private String name;

    /**
     * 字段类型
     **/
    private String type;

    /**
     * 字段注释
     **/
    private String comment;

}
