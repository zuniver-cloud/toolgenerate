package com.fy.tool.toolmaker.vo;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Classify implements Serializable {
    //分类描述名称
    private String name;
    //分类值
    private String value;
}
