rm docs/UML/classes/*.*
rm docs/UML/diagrams/*.*

./uml_generate.sh -i {lang_release} -r LANG -o docs/UML computable/UML/openEHR_UML-LANG.mdzip
