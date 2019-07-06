rm -f docs/UML/classes/*.*
rm -f docs/UML/diagrams/*.*

../specifications-AA_GLOBAL/bin/uml_generate.sh -i {lang_release} -r LANG -o docs/UML computable/UML/openEHR_UML-LANG.mdzip
