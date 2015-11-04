# ============================================================================
#
# Git Helpers
# ===========
#
# This file contains support CMake script for working with database models.
#
# Usage
# -----
#
# The file is NOT included by pile_support.cmake; the user
# user has to import the file:
#
#    include(pile_model_to_cpp)
#
# At initialization time the script creates a file (run_edit_bin.bat)
# that can be used to edit a binary. It Takes a single argument (the path
# towards the file to edit).
# ============================================================================

find_package(PythonInterp)

# default prefix for generated file name
if (NOT pile_expand_sql_schema__prefix)
    set (pile_expand_sql_schema__prefix "autogen-")
endif()

# default suffix for generated file name
if (NOT pile_expand_sql_schema__suffix)
    set (pile_expand_sql_schema__suffix "")
endif()

# default base class for generated file name
if (NOT pile_expand_sql_schema__base_class)
    set (pile_expand_sql_schema__base_class "Model")
endif()


# this is the content of the script to be executed
set (pile_expand_sql_schema__script
"#!/usr/bin/env python

import sys, os, traceback
from collections import OrderedDict

override_names = {
    'accesstoken': 'AccessToken',
    'rolemapping': 'RoleMapping'
}

def buildTable(table_name, base_class, columns, output_dir, template_h, template_cc):
    out_h_cont = template_h
    out_cc_cont = template_cc

    table_name_u = table_name.upper()
    table_name_l = table_name.lower()
    table_name = table_name # .title()

    out_file_h = '${pile_expand_sql_schema__prefix}' + table_name_l + '${pile_expand_sql_schema__suffix}.h'
    out_file_cc = '${pile_expand_sql_schema__prefix}' + table_name_l + '${pile_expand_sql_schema__suffix}.cc'

    column_defs = ''
    copy_constr = ''
    default_constr = ''
    id_column = -1
    assign_constr = ''
    pipe_columns = ''
    case_columns = ''
    bind_columns = ''
    bind_one_column = ''
    ids_columns = ''
    comma_columns = ''
    column_columns = ''
    assign_columns = ''
    comma_columns_no_id = ''
    retreive_columns = ''
    record_columns = ''
    i = -1
    for i, col in enumerate(columns):
        col_value = columns[col]
        copy_constr = copy_constr + '        ' + col + ' (other.' + col + '),\\n'
        column_defs = column_defs + '    ' + col_value + ' ' + col + ';\\n'
        if col == 'id' and col_value == 'long':
            default_constr = default_constr + '        ' + col + '(ID_NEW_INSTANCE),\\n'
            id_column = i
        else:
            default_constr = default_constr + '        ' + col + '(),\\n'

        assign_constr = assign_constr + '        ' + col + ' = other.' + col + ';\\n'
        pipe_columns = pipe_columns + '        << \"' + col + '\"\\n'
        case_columns = case_columns + '    case ' + str(i) + ': result = \"' + col + '\"; break;\\n'
        bind_one_column = bind_one_column + '    case ' + str(i) + ': query.bindValue (\":' + col + '\", ' + col + '); break;\\n'
        ids_columns = ids_columns + '        COLID_' + col.upper() + ' = ' + str(i) + ',\\n'
        comma_columns = comma_columns + '            \"' + col + ',\"\\n'
        bind_columns = bind_columns + '    query.bindValue (\":' + col + '\", ' + col + ');\\n'
        if col != 'id':
            comma_columns_no_id = comma_columns_no_id + '            \"' + col + ',\"\\n'
            column_columns = column_columns + '            \":' + col + ',\"\\n'
            assign_columns = assign_columns + '            \"' + col + '=:' + col + ',\"\\n'
        to_converter = 'UNKNOWN'
        to_cast = ''
        if col_value == 'QString':
            to_converter = 'toString ()'
        elif col_value == 'int':
            to_converter = 'toInt (&b_one); b_ret = b_ret & b_one'
        elif col_value == 'double':
            to_converter = 'toDouble (&b_one); b_ret = b_ret & b_one'
        elif col_value == 'long':
            to_converter = 'toLongLong (&b_one); b_ret = b_ret & b_one'
            to_cast = '(long)'
        elif col_value == 'QDateTime':
            to_converter = 'toDateTime ()'
        elif col_value == 'QDate':
            to_converter = 'toDate ()'
        elif col_value == 'bool':
            to_converter = 'toBool ()'
        retreive_columns = retreive_columns + '    ' + col + ' = ' + to_cast + 'query.value (' + str(i) + ').' + to_converter + ';\\n'
        record_columns = record_columns + '    ' + col + ' = ' + to_cast + 'rec.value (\"' + col + '\").' + to_converter + ';\\n'

    default_constr = default_constr[:-2]
    if id_column == -1:
        id_column = 'ID_UNAVAILABLE'
        get_id_result = 'ID_UNAVAILABLE'
        set_id = '// id unavailable in this model'
    elif columns['id'] != 'long':
        get_id_result = 'ID_UNAVAILABLE'
        set_id = '// id unavailable in this model'
    else:
        get_id_result = 'id'
        set_id = 'id = value'

    column_defs = column_defs[:-1]
    copy_constr = copy_constr[:-2]
    assign_constr = assign_constr[:-1]
    pipe_columns = pipe_columns[:-1]
    case_columns = case_columns[:-1]
    bind_columns = bind_columns[:-1]
    bind_one_column = bind_one_column[:-1]
    ids_columns = ids_columns + '\\n        COLID_MAX = ' + str(i+1)
    comma_columns = comma_columns[:-3] + '\"'
    comma_columns_no_id = comma_columns_no_id[:-3] + '\"'
    column_columns = column_columns[:-3] + '\"'
    assign_columns = assign_columns[:-3] + '\"'

    def processString(sin):
        sin = sin.replace('$TABLE_NAME$', table_name)
        sin = sin.replace('$TABLE_NAME_U$', table_name_u)
        sin = sin.replace('$TABLE_NAME_L$', table_name_l)
        sin = sin.replace('$COLUMN_COUNT$', str(len(columns)))
        sin = sin.replace('$FILE_CC$', out_file_cc)
        sin = sin.replace('$FILE_H$', out_file_h)
        sin = sin.replace('$COLUMNS_DEFS$', column_defs)
        sin = sin.replace('$COPY_CONSTR$', copy_constr)
        sin = sin.replace('$ASSIGN_CONSTR$', assign_constr)
        sin = sin.replace('$DEFAULT_CONSTR$', default_constr)
        sin = sin.replace('$PIPE_COLUMNS$', pipe_columns)
        sin = sin.replace('$CASE_COLUMNS$', case_columns)
        sin = sin.replace('$BIND_COLUMNS$', bind_columns)
        sin = sin.replace('$RETREIVE_COLUMNS$', retreive_columns)
        sin = sin.replace('$RECORD_COLUMNS$', record_columns)
        sin = sin.replace('$COLUMN_IDS$', ids_columns)
        sin = sin.replace('$BIND_ONE_COLUMN$', bind_one_column)
        sin = sin.replace('$ID_COLUMN$', str(id_column))
        sin = sin.replace('$GET_ID_RESULT$', str(get_id_result))
        sin = sin.replace('$SET_ID_RESULT$', str(set_id))
        sin = sin.replace('$COMMA_COLUMNS$', comma_columns)
        sin = sin.replace('$COMMA_COLUMNS_NO_ID$', comma_columns_no_id)
        sin = sin.replace('$COLUMN_COLUMNS$', column_columns)
        sin = sin.replace('$ASSIGN_COLUMNS$', assign_columns)
        sin = sin.replace('$BASE_CLASS$', base_class)
        sin = sin.replace('$BASE_CLASS_L$', base_class.lower())
        sin = sin.replace('$BASE_CLASS_U$', base_class.upper())
        return sin


    out_h_cont = processString(out_h_cont)
    out_cc_cont = processString(out_cc_cont)

    out_file_h = os.path.join(output_dir, out_file_h)
    out_file_cc = os.path.join(output_dir, out_file_cc)

    with open (out_file_h, 'w') as myfile:
        myfile.write(out_h_cont)
    with open (out_file_cc, 'w') as myfile:
        myfile.write(out_cc_cont)

def main(argv):
    # meaningful names to arguments
    schema_file, output_dir, template_h_file, template_cc_file, view_h_file, view_cc_file = argv
    # read input files
    with open (template_h_file, 'r') as myfile:
        template_h=myfile.read()
    with open (template_cc_file, 'r') as myfile:
        template_cc=myfile.read()
    with open (view_h_file, 'r') as myfile:
        view_h=myfile.read()
    with open (view_cc_file, 'r') as myfile:
        view_cc=myfile.read()

    table_count = 0
    table_name = ''
    base_class = ''
    with open (schema_file, 'r') as myfile:
        b_in_table = False
        b_is_view = False
        columns = OrderedDict()
        for line in myfile:
            components = line.strip().upper().split(' ')
            comp_orig = line.strip().split(' ')
            if b_in_table:
                if len(components) == 1 and components[0].endswith(';'):
                    b_in_table = False
                    table_count = table_count + 1
                    if b_is_view:
                        buildTable(table_name, base_class, columns, output_dir, view_h, view_cc)
                    else:
                        buildTable(table_name, base_class, columns, output_dir, template_h, template_cc)
                    columns = OrderedDict()
                    table_name = ''
                elif len(components) >= 1:
                    if components[0].startswith('`') and components[0].endswith('`'):
                        datatype = components[1].replace(',', '')
                        col_name = comp_orig[0][1:-1]
                        if datatype.startswith('VARCHAR'):
                            datatype = 'QString'
                        elif datatype == 'TINYINT(1)':
                            datatype = 'bool'
                        elif datatype == 'TEXT':
                            datatype = 'QString'
                        elif datatype == 'DATETIME':
                            datatype = 'QDateTime'
                        elif datatype == 'DOUBLE':
                            datatype = 'double'
                        elif datatype.startswith('INT('):
                            datatype = 'long'
                        else:
                            print 'WARNING! Unknown data type: ', datatype

                        columns[col_name] = datatype
                    elif b_is_view:
                        if len(components) >= 5 and components[0] == 'SELECT' and components[1] == '*' and components[2] == 'FROM' and components[4] == 'WHERE':
                            base_class = comp_orig[3]
                    else:
                        if len(components) >= 3 and components[0] == 'PRIMARY' and components[1] == 'KEY':
                            pass
            else:
                if len(components) >= 3 and components[0] == 'CREATE' and components[1] == 'TABLE':
                    # print '---- table ----'
                    b_is_view = False
                elif len(components) >= 3 and components[0] == 'CREATE' and components[1] == 'VIEW':
                    # print '---- view ----'
                    b_is_view = True
                else:
                    continue

                base_class = '${pile_expand_sql_schema__base_class}'
                b_in_table = True
                for c in comp_orig:
                    if c.startswith('`') and c.endswith('`'):
                        table_name = c[1:-1]
                        break
                try:
                    table_name = override_names[table_name.lower()]
                except:
                    pass
                # print table_name

    print table_count, 'tables expanded'
    sys.exit(0)

if __name__ == '__main__':
    try:
        main(sys.argv[1:])
    except Exception as e:
        print e
        traceback.print_exc(file=sys.stdout)
        sys.exit(1)
")

# write the script in build directory
set (pile_expand_sql_schema__script_path
    "${CMAKE_CURRENT_BINARY_DIR}/pileExpandSqlSchema.py")
file(WRITE "${pile_expand_sql_schema__script_path}"
    "${pile_expand_sql_schema__script}")

# Create a target that processes a schema file into c++ source files.
#
# Arguments
#     - target: name of the target to be generated
#     - schema: full path to the .sql file containing the schema
#     - output: the path where the files are to be generated
#     - template_h: template for header files
#     - template_cc: template for source files
#
# Following variables are replaced in templates:
#     -
#

macro    (pileExpandSqlSchema pile_expand_sql_schema__target
                              pile_expand_sql_schema__schema
                              pile_expand_sql_schema__output
                              pile_expand_sql_schema__tbl_template_h
                              pile_expand_sql_schema__tbl_template_cc
                              pile_expand_sql_schema__view_template_h
                              pile_expand_sql_schema__view_template_cc)

    message (STATUS "target = ${pile_expand_sql_schema__target}")
    message (STATUS "schema = ${pile_expand_sql_schema__schema}")
    message (STATUS "output = ${pile_expand_sql_schema__output}")
    message (STATUS "t_h = ${pile_expand_sql_schema__tbl_template_h}")
    message (STATUS "t_cc = ${pile_expand_sql_schema__tbl_template_cc}")
    message (STATUS "v_h = ${pile_expand_sql_schema__view_template_h}")
    message (STATUS "v_cc = ${pile_expand_sql_schema__view_template_cc}")

    if (NOT PYTHONINTERP_FOUND)
        message (FATAL_ERROR "Python interpreter was not found; can't use pileExpandSqlSchema")
    endif()

    add_custom_target(
        "${pile_expand_sql_schema__target}" ALL
        "${PYTHON_EXECUTABLE}"
            "${pile_expand_sql_schema__script_path}"
            "${pile_expand_sql_schema__schema}"
            "${pile_expand_sql_schema__output}"
            "${pile_expand_sql_schema__tbl_template_h}"
            "${pile_expand_sql_schema__tbl_template_cc}"
            "${pile_expand_sql_schema__view_template_h}"
            "${pile_expand_sql_schema__view_template_cc}"
        DEPENDS
            "${pile_expand_sql_schema__schema}"
            "${pile_expand_sql_schema__tbl_template_h}"
            "${pile_expand_sql_schema__tbl_template_cc}"
            "${pile_expand_sql_schema__view_template_h}"
            "${pile_expand_sql_schema__view_template_cc}"
        WORKING_DIRECTORY
            "${pile_expand_sql_schema__output}"
        COMMENT "Expanding Sql models"
        VERBATIM
        SOURCES
            "${pile_expand_sql_schema__schema}"
            "${pile_expand_sql_schema__tbl_template_h}"
            "${pile_expand_sql_schema__tbl_template_cc}"
            "${pile_expand_sql_schema__view_template_h}"
            "${pile_expand_sql_schema__view_template_cc}")

    # also generate this right now so CMake finds files
    # generated by this process
    execute_process(
        COMMAND "${PYTHON_EXECUTABLE}"
            "${pile_expand_sql_schema__script_path}"
            "${pile_expand_sql_schema__schema}"
            "${pile_expand_sql_schema__output}"
            "${pile_expand_sql_schema__tbl_template_h}"
            "${pile_expand_sql_schema__tbl_template_cc}"
            "${pile_expand_sql_schema__view_template_h}"
            "${pile_expand_sql_schema__view_template_cc}"
        WORKING_DIRECTORY
            "${pile_expand_sql_schema__output}"
            OUTPUT_QUIET)


endmacro(pileExpandSqlSchema)

# ============================================================================

