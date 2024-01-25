package com.fy.tool.toolmaker.vo;


import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Field implements Serializable {
    private String name;
    private String type;
    private String showName;
    private String parentTable;
}
