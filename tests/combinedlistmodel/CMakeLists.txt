add_single_file_unit_test(combinedlistmodel)

# For QAbstractItemModelTester.
target_link_libraries(tst_combinedlistmodel PRIVATE Qt6::Test)
