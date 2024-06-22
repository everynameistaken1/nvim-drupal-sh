local Q = {}

Q.StandardServices = [[
    (block_mapping_pair
      key: (flow_node
        (plain_scalar
          (string_scalar) @serviceColl (#eq? @serviceColl "services")
        )
      )
      value: (block_node
        (block_mapping
          (block_mapping_pair
            key: (flow_node
              (plain_scalar
                (string_scalar) @serviceName (#offset! @serviceName)
              )
            )
            value: (block_node
              (block_mapping
                (block_mapping_pair
                  key: (flow_node
                    (plain_scalar
                      (string_scalar) @classField (#eq? @classField "class")
                    )
                  )
                  value: (flow_node
                    (plain_scalar
                      (string_scalar) @classValue (#offset! @classValue)
                    )
                  )
                )
              )
            ) @serviceBody
          )
        )
      )
    )
]]

Q.ServiceArgs = [[
(flow_node
  (plain_scalar
    (string_scalar) @classValue (#offset! @classValue)
  )
)
]]

Q.ClassRange = [[
(class_declaration
 body: (declaration_list) @declList
)
]]

Q.GetBaseRange = [[
(class_declaration 
 (base_clause) @baseClause
)
]]

Q.InterfaceExists = [[
(class_declaration 
 (base_clause) @baseClause
 (class_interface_clause) @interface
)
]]

Q.ConstructorRange = [[
(method_declaration
 name: (name) @name (#eq? @name "__construct")
) @constructor
]]

Q.CreateParamExists = [[
(method_declaration
 name: (name) @methodName (#eq? @methodName "create")
 body: (compound_statement
  (return_statement
   (object_creation_expression
    (arguments
     (argument) @name
    )
   )
  )
 )
)
]]

Q.ConstructorParamExists = [[
(method_declaration
 name: (name) @methodName (#eq? @methodName "__construct")
 parameters: (formal_parameters
  (property_promotion_parameter) @param
 )
)
]]

Q.Namespace = [[
(namespace_definition) @namespace
]]

Q.NamespaceName = [[
(namespace_use_declaration) @name
]]

Q.ConstructorExists = [[
(method_declaration
 name: (name) @methodName (#eq? @methodName "__construct")
)
]]

Q.StaticCreateReturnRange = [[
(method_declaration
 name: (name) @name (#eq? @name "create")
 body: (compound_statement
  (return_statement
   (object_creation_expression
    (arguments) @args
   )
  )
 )
)
]]



Q.ConstructorParamsCount = [[
(method_declaration
 (visibility_modifier)
 name: (name) @name (#eq? @name "__construct")
 parameters: (formal_parameters
  (simple_parameter) @param
  )
)
]]

Q.StaticCreateParamCount = [[
(method_declaration
 (visibility_modifier)
 (static_modifier)
 name: (name) @name (#eq? @name "create")
 parameters: (formal_parameters
  (simple_parameter) @param
 )
)
]]

Q.StaticCreateExists = [[
(method_declaration
 (visibility_modifier)
 (static_modifier)
 name: (name) @name (#eq? @name "create")
)
]]

Q.CapturePromotingParamsInConstructor = [[
(
 (method_declaration
  name: (name) @methodName (#eq? @methodName "__construct")
  parameters: (formal_parameters
   (property_promotion_parameter) @promParam
  )
 )
) @res
]]

Q.ServiceInjectionLocation = [[
(
 (method_declaration
  name: (name) @methodName (#eq? @methodName "__construct")
  parameters: (formal_parameters) @formParam
 )
) @res
]]


return Q
