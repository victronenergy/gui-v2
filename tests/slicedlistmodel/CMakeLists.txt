add_single_file_unit_test(slicedlistmodel)

# For QAbstractItemModelTester.
target_link_libraries(tst_slicedlistmodel PRIVATE Qt6::Test)
