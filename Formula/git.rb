class Git < Formula
  desc "Distributed revision control system"
  homepage "https://git-scm.com"
  url "https://www.kernel.org/pub/software/scm/git/git-2.12.0.tar.xz"
  sha256 "1821766479062d052cc1897d0ded95212e81e5c7f1039786bc4aec2225a32027"
  head "https://github.com/git/git.git", :shallow => false

  bottle do
    sha256 "db6876e519c871fdfb0f4b2412810eae081a84f6489015791540ed2fd1f77ef7" => :sierra
    sha256 "b9e1276047be119df704f196affd69b69a31348e052f960b9f59b16e22d085fc" => :el_capitan
    sha256 "ac19aaa880323214874a9be2eb98b25d07eafcdecf9e04e0c97df5ddfca9b892" => :yosemite
  end

  option "with-blk-sha1", "Compile with the block-optimized SHA1 implementation"
  option "without-completions", "Disable bash/zsh completions from 'contrib' directory"
  option "with-brewed-openssl", "Build with Homebrew OpenSSL instead of the system version"
  option "with-brewed-curl", "Use Homebrew's version of cURL library"
  option "with-brewed-svn", "Use Homebrew's version of SVN"
  option "with-persistent-https", "Build git-remote-persistent-https from 'contrib' directory"

  depends_on "pcre" => :optional
  depends_on "gettext" => :optional
  depends_on "openssl" if build.with? "brewed-openssl"
  depends_on "curl" if build.with? "brewed-curl"
  depends_on "go" => :build if build.with? "persistent-https"
  # Trigger an install of swig before subversion, as the "swig" doesn't get pulled in otherwise
  # See https://github.com/Homebrew/homebrew/issues/34554
  if build.with? "brewed-svn"
    depends_on "swig"
    depends_on "subversion" => "with-perl"
  end

  resource "html" do
    url "https://www.kernel.org/pub/software/scm/git/git-htmldocs-2.12.0.tar.xz"
    sha256 "bd548faa2c9e63403e528ce4f4e87561e78949a0349a9e2a27e0d6e581d3a8bd"
  end

  resource "man" do
    url "https://www.kernel.org/pub/software/scm/git/git-manpages-2.12.0.tar.xz"
    sha256 "8b8356f8d50eff6499c5d05e87c106a7b1b48bd16de1742fa022631909804773"
  end

  patch :DATA

  def install
    # If these things are installed, tell Git build system not to use them
    ENV["NO_FINK"] = "1"
    ENV["NO_DARWIN_PORTS"] = "1"
    ENV["V"] = "1" # build verbosely
    ENV["NO_R_TO_GCC_LINKER"] = "1" # pass arguments to LD correctly
    ENV["PYTHON_PATH"] = which "python"
    ENV["PERL_PATH"] = which "perl"

    perl_version = /\d\.\d+/.match(`perl --version`)

    if build.with? "brewed-svn"
      ENV["PERLLIB_EXTRA"] = %W[
        #{Formula["subversion"].opt_lib}/perl5/site_perl
        #{Formula["subversion"].opt_prefix}/Library/Perl/#{perl_version}/darwin-thread-multi-2level
      ].join(":")
    elsif MacOS.version >= :mavericks
      ENV["PERLLIB_EXTRA"] = %W[
        #{MacOS.active_developer_dir}
        /Library/Developer/CommandLineTools
        /Applications/Xcode.app/Contents/Developer
      ].uniq.map do |p|
        "#{p}/Library/Perl/#{perl_version}/darwin-thread-multi-2level"
      end.join(":")
    end

    unless quiet_system ENV["PERL_PATH"], "-e", "use ExtUtils::MakeMaker"
      ENV["NO_PERL_MAKEMAKER"] = "1"
    end

    ENV["BLK_SHA1"] = "1" if build.with? "blk-sha1"

    if build.with? "pcre"
      ENV["USE_LIBPCRE"] = "1"
      ENV["LIBPCREDIR"] = Formula["pcre"].opt_prefix
    end

    ENV["NO_GETTEXT"] = "1" if build.without? "gettext"

    args = %W[
      prefix=#{prefix}
      sysconfdir=#{etc}
      CC=#{ENV.cc}
      CFLAGS=#{ENV.cflags}
      LDFLAGS=#{ENV.ldflags}
    ]
    args << "NO_OPENSSL=1" << "APPLE_COMMON_CRYPTO=1" if build.without? "brewed-openssl"

    system "make", "install", *args

    # Install the macOS keychain credential helper
    cd "contrib/credential/osxkeychain" do
      system "make", "CC=#{ENV.cc}",
                     "CFLAGS=#{ENV.cflags}",
                     "LDFLAGS=#{ENV.ldflags}"
      bin.install "git-credential-osxkeychain"
      system "make", "clean"
    end

    # Install the netrc credential helper
    cd "contrib/credential/netrc" do
      system "make", "test"
      bin.install "git-credential-netrc"
    end

    # Install git-subtree
    cd "contrib/subtree" do
      system "make", "CC=#{ENV.cc}",
                     "CFLAGS=#{ENV.cflags}",
                     "LDFLAGS=#{ENV.ldflags}"
      bin.install "git-subtree"
    end

    if build.with? "persistent-https"
      cd "contrib/persistent-https" do
        system "make"
        bin.install "git-remote-persistent-http",
                    "git-remote-persistent-https",
                    "git-remote-persistent-https--proxy"
      end
    end

    if build.with? "completions"
      # install the completion script first because it is inside "contrib"
      bash_completion.install "contrib/completion/git-completion.bash"
      bash_completion.install "contrib/completion/git-prompt.sh"

      zsh_completion.install "contrib/completion/git-completion.zsh" => "_git"
      cp "#{bash_completion}/git-completion.bash", zsh_completion
    end

    elisp.install Dir["contrib/emacs/*.el"]
    (share/"git-core").install "contrib"

    # We could build the manpages ourselves, but the build process depends
    # on many other packages, and is somewhat crazy, this way is easier.
    man.install resource("man")
    (share/"doc/git-doc").install resource("html")

    # Make html docs world-readable
    chmod 0644, Dir["#{share}/doc/git-doc/**/*.{html,txt}"]
    chmod 0755, Dir["#{share}/doc/git-doc/{RelNotes,howto,technical}"]

    # To avoid this feature hooking into the system OpenSSL, remove it.
    # If you need it, install git --with-brewed-openssl.
    rm "#{libexec}/git-core/git-imap-send" if build.without? "brewed-openssl"

    # Set the macOS keychain credential helper by default
    # (as Apple's CLT's git also does this).
    (buildpath/"gitconfig").write <<-EOS.undent
      [credential]
      \thelper = osxkeychain
    EOS
    etc.install "gitconfig"
  end

  test do
    system bin/"git", "init"
    %w[haunted house].each { |f| touch testpath/f }
    system bin/"git", "add", "haunted", "house"
    system bin/"git", "commit", "-a", "-m", "Initial Commit"
    assert_equal "haunted\nhouse", shell_output("#{bin}/git ls-files").strip
  end
end

__END__
commit f53c5de29cec68e3294a008052251631eaffcf07
Author: SZEDER Gábor <szeder.dev@gmail.com>
Date:   Sat Mar 18 19:24:08 2017 +0100

    pickaxe: fix segfault with '-S<...> --pickaxe-regex'
    
    'git {log,diff,...} -S<...> --pickaxe-regex' can segfault as a result
    of out-of-bounds memory reads.
    
    diffcore-pickaxe.c:contains() looks for all matches of the given regex
    in a buffer in a loop, advancing the buffer pointer to the end of the
    last match in each iteration.  When we switched to REG_STARTEND in
    b7d36ffca (regex: use regexec_buf(), 2016-09-21), we started passing
    the size of that buffer to the regexp engine, too.  Unfortunately,
    this buffer size is never updated on subsequent iterations, and as the
    buffer pointer advances on each iteration, this "bufptr+bufsize"
    points past the end of the buffer.  This results in segmentation
    fault, if that memory can't be accessed.  In case of 'git log' it can
    also result in erroneously listed commits, if the memory past the end
    of buffer is accessible and happens to contain data matching the
    regex.
    
    Reduce the buffer size on each iteration as the buffer pointer is
    advanced, thus maintaining the correct end of buffer location.
    Furthermore, make sure that the buffer pointer is not dereferenced in
    the control flow statements when we already reached the end of the
    buffer.
    
    The new test is flaky, I've never seen it fail on my Linux box even
    without the fix, but this is expected according to db5dfa3 (regex:
    -G<pattern> feeds a non NUL-terminated string to regexec() and fails,
    2016-09-21).  However, it did fail on Travis CI with the first (and
    incomplete) version of the fix, and based on that commit message I
    would expect the new test without the fix to fail most of the time on
    Windows.
    
    Signed-off-by: SZEDER Gábor <szeder.dev@gmail.com>
    Signed-off-by: Junio C Hamano <gitster@pobox.com>

diff --git a/diffcore-pickaxe.c b/diffcore-pickaxe.c
index 8413d76..e627140 100644
--- a/diffcore-pickaxe.c
+++ b/diffcore-pickaxe.c
@@ -79,12 +79,15 @@ static unsigned int contains(mmfile_t *mf, regex_t *regexp, kwset_t kws)
 		regmatch_t regmatch;
 		int flags = 0;
 
-		while (*data &&
+		while (sz && *data &&
 		       !regexec_buf(regexp, data, sz, 1, &regmatch, flags)) {
 			flags |= REG_NOTBOL;
 			data += regmatch.rm_eo;
-			if (*data && regmatch.rm_so == regmatch.rm_eo)
+			sz -= regmatch.rm_eo;
+			if (sz && *data && regmatch.rm_so == regmatch.rm_eo) {
 				data++;
+				sz--;
+			}
 			cnt++;
 		}
 
diff --git a/t/t4062-diff-pickaxe.sh b/t/t4062-diff-pickaxe.sh
index f0bf50b..7c4903f 100755
--- a/t/t4062-diff-pickaxe.sh
+++ b/t/t4062-diff-pickaxe.sh
@@ -19,4 +19,9 @@ test_expect_success '-G matches' '
 	test 4096-zeroes.txt = "$(cat out)"
 '
 
+test_expect_success '-S --pickaxe-regex' '
+	git diff --name-only -S0 --pickaxe-regex HEAD^ >out &&
+	verbose test 4096-zeroes.txt = "$(cat out)"
+'
+
 test_done
