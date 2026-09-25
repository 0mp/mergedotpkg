#! /usr/libexec/atf-sh

set_up() {
	mock_dir="$(atf_get_srcdir)/mock"

	# Install mergedotpkg into the test directory.
	prefix="${PWD}/usr/local"
	mkdir -p "$prefix"
	make -C "$(atf_get_srcdir)/.." PREFIX="$prefix" install

	# Add the temporary prefix to PATH.
	PATH="${prefix}/bin:${PATH}"
	# Add the mock programs to PATH.
	PATH="${mock_dir}:${PATH}"
	export PATH

	# Configure the mock editor.
	mock_editor="${PWD}/ed"
	touch "$mock_editor"
	chmod +x "$mock_editor"
	export EDITOR="$mock_editor"
	export VISUAL="$mock_editor"

	# Copy fixtures to the test directory.
	cp -a "$(atf_get_srcdir)/fixtures/$(atf_get ident)/"* .
	find . -name '*fixture' -exec sh -c 'cp "$1" "${1%.fixture}"' _sh {} \;

	# Set the cache directory.
	export XDG_CACHE_DIR="${PWD}/cache"
	mkdir "$XDG_CACHE_DIR"
}

atf_test_case backup
backup_head() { atf_set "descr" "Backup of /etc/group and /etc/group.pkgnew"; }
backup_body() {
	set_up

	export MOCK_SDIFF_SESSION='l\nl\nr\neb\nr\nl\n'
	export MOCK_READ_YES='true'
	cat > "$mock_editor" <<'EOF'
#!/bin/sh
printf '1c\nvideo:*:44:0mp\n.\nwq\n' | ed -s "$1"
EOF

	atf_check -s exit:0 -o ignore -e ignore mergedotpkg -d .
	for name in group group.pkgnew; do
		cached_filepath="$(find ./cache -name "$name")"
		atf_check -o file:"$cached_filepath" cat "./etc/${name}.fixture"
	done
}

atf_test_case merge_etc_group
merge_etc_group_head() { atf_set "descr" "Merge /etc/group"; }
merge_etc_group_body() {
	set_up

	export MOCK_SDIFF_SESSION='l\nl\nr\neb\nr\nl\n'
	export MOCK_READ_YES='true'
	cat > "$mock_editor" <<'EOF'
#!/bin/sh
printf '1c\nvideo:*:44:0mp\n.\nwq\n' | ed -s "$1"
EOF

	atf_check -s exit:0 -o ignore -e ignore mergedotpkg -d .
	atf_check -o file:"group.expected" cat group
}

atf_test_case processed_files_removal
processed_files_removal_head() { atf_set "descr" "Removal of .merged and .pkg*"; }
processed_files_removal_body() {
	set_up

	export MOCK_SDIFF_SESSION='l\nl\nr\neb\nr\nl\n'
	export MOCK_READ_YES='true'
	cat > "$mock_editor" <<'EOF'
#!/bin/sh
printf '1c\nvideo:*:44:0mp\n.\nwq\n' | ed -s "$1"
EOF

	atf_check -s exit:0 -o ignore -e ignore mergedotpkg -d .
	atf_check -s exit:0 test -e "./etc/group"
	atf_check -s exit:0 test ! -e "./etc/group.pkgnew"
	atf_check -s exit:0 test ! -e "./etc/group.pkgnew.merged"
}

atf_init_test_cases()
{
	atf_add_test_case backup
	atf_add_test_case merge_etc_group
	atf_add_test_case processed_files_removal
}
