use ExtUtils::MakeMaker;

WriteMakefile(
	      'NAME'           => 'Net-HL7',
	      'VERSION'        => 0.65,
	      'AUTHOR'         => 'D.A.Dokter <dokter@wyldebeast-wunderliebe.com>',
	      'INSTALLDIRS'    => 'perl',
	      'INSTALLMAN1DIR' => '$(PREFIX)/man/man1',
	      'INSTALLMAN3DIR' => '$(PREFIX)/man/man3',
	      'INSTALLARCHLIB' => '$(PREFIX)/lib',
	      'INSTALLPRIVLIB' => '$(PREFIX)/lib'
);
