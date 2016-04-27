class Hollywood < Formula
  desc "fill your console with Hollywood melodrama technobabble"
  homepage "https://launchpad.net/hollywood"
  url "https://launchpad.net/ubuntu/+archive/primary/+files/hollywood_1.7.orig.tar.gz"
  sha256 "20684e1a0360ef32fb418f09851361d32d93707816834b60ec80af4ebcc7a600"

  depends_on "byobu"
  depends_on "coreutils"
  depends_on "moreutils"
  depends_on "ccze"

  patch :DATA

  def install
    bin.install "bin/hollywood"
    lib.install "lib/hollywood"
    share.install "share/hollywood"
    man1.install "share/man/man1/hollywood.1"
  end
end

__END__
diff --git a/bin/hollywood b/bin/hollywood
index 5e14e72..9c0f902 100755
--- a/bin/hollywood
+++ b/bin/hollywood
@@ -20,11 +20,11 @@
 set -e
 
 PKG="hollywood"
-trap "pkill -f -9 lib/hollywood/ >/dev/null 2>&1; exit 0" EXIT HUP INT QUIT TERM
+trap "pkill -9 -f lib/hollywood/ >/dev/null 2>&1; exit 0" EXIT HUP INT QUIT TERM
 
 dir="-v"
 widget_dir="$(dirname $0)/../lib/$PKG"
-widget1=$(ls "$widget_dir/" | sort -R | head -n1)
+widget1=$(ls "$widget_dir/" | gsort -R | head -n1)
 
 if [ -n "$1" ]; then
 	SPLITS="$1"
@@ -49,7 +49,7 @@ tmux new-window -n $PKG "$widget_dir/$widget1" \; \
 
 split=1
 sleep 0.5
-for w in $(ls "$widget_dir" | sort -R); do
+for w in $(ls "$widget_dir" | gsort -R); do
 	[ "$w" = "$widget1" ] && continue
 	[ "$dir" = "-v" ] && dir="-h" || dir="-v"
 	panes=$(tmux lsp -t $PKG)
diff --git a/lib/hollywood/apg b/lib/hollywood/apg
index 3754327..cf4c9a8 100755
--- a/lib/hollywood/apg
+++ b/lib/hollywood/apg
@@ -16,8 +16,8 @@
 
 command -v apg >/dev/null 2>&1 || exit 1
 
-trap "pkill -f -9 lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
+trap "pkill -9 -f lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
 while true; do
-	apg -qlt -c /dev/urandom | awk '{print $3}' | sed -e "s/-/ /g" | ccze -A -c default=magenta
+	apg -qlt -c /dev/urandom | awk '{print $3}' | gsed -e "s/-/ /g" | ccze -A -c default=magenta
 	sleep 1.1
 done
diff --git a/lib/hollywood/bmon b/lib/hollywood/bmon
index cc3632b..4fc8690 100755
--- a/lib/hollywood/bmon
+++ b/lib/hollywood/bmon
@@ -16,7 +16,7 @@
 
 command -v bmon >/dev/null 2>&1 || exit 1
 
-trap "pkill -f -9 lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
+trap "pkill -9 -f lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
 while true; do
 	bmon
 done
diff --git a/lib/hollywood/cmatrix b/lib/hollywood/cmatrix
index 8325c9c..95c0edf 100755
--- a/lib/hollywood/cmatrix
+++ b/lib/hollywood/cmatrix
@@ -16,7 +16,7 @@
 
 command -v cmatrix >/dev/null 2>&1 || exit 1
 
-trap "pkill -f -9 lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
+trap "pkill -9 -f lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
 while true; do
 	cmatrix -b
 done
diff --git a/lib/hollywood/code b/lib/hollywood/code
index 4bae6b5..18c2684 100755
--- a/lib/hollywood/code
+++ b/lib/hollywood/code
@@ -17,9 +17,9 @@
 command -v locate >/dev/null 2>&1 || exit 1
 command -v view >/dev/null 2>&1 || exit 1
 
-trap "pkill -f -9 lib/hollywood/ >/dev/null 2>&1" EXIT HUP INT QUIT TERM
+trap "pkill -9 -f lib/hollywood/ >/dev/null 2>&1" EXIT HUP INT QUIT TERM
 while true; do
-	FILES=$(locate "/usr/*.java" "/usr/*.c" "/usr/*.cpp" | sort -R | head -n 4096)
+	FILES=$(locate "/usr/*.java" "/usr/*.c" "/usr/*.cpp" | gsort -R | head -n 4096)
 	for f in $FILES; do
 		[ -r "$f" ] || continue
 		[ -s "$f" ] || continue
@@ -27,7 +27,7 @@ while true; do
 		lines=$(wc -l "$f" | awk '{print $1}')
 		[ "$lines" -gt 100 ] || continue
 		l=$(($lines*$RANDOM/32767))
-		if timeout --foreground 2s view +$l "$f" 2>/dev/null; then
+		if gtimeout --foreground 2s view +$l "$f" 2>/dev/null; then
 			reset
 			exit 0
 		fi
diff --git a/lib/hollywood/errno b/lib/hollywood/errno
index 92c4508..980ee1a 100755
--- a/lib/hollywood/errno
+++ b/lib/hollywood/errno
@@ -16,8 +16,8 @@
 
 command -v errno >/dev/null 2>&1 || exit 1
 
-trap "pkill -f -9 lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
+trap "pkill -9 -f lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
 while true; do
-	errno --list | sort -R | ccze -A
+	errno --list | gsort -R | ccze -A
 	sleep 0.6
 done
diff --git a/lib/hollywood/hexdump b/lib/hollywood/hexdump
index c5b6d45..133680a 100755
--- a/lib/hollywood/hexdump
+++ b/lib/hollywood/hexdump
@@ -17,10 +17,10 @@
 command -v hexdump >/dev/null 2>&1 || exit 1
 command -v ccze >/dev/null 2>&1 || exit 1
 
-trap "pkill -f -9 lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
+trap "pkill -9 -f lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
 while true; do
-	for f in $(ls /usr/bin/ | sort -R); do
-		head -c 4096 "/usr/bin/$f" | hexdump -C | ccze -A -c default=green -c dir="bold green"
+	for f in $(ls /usr/bin/ | gsort -R); do
+		head -c 4096 "/usr/bin/$f" | hexdump -C | ccze -A -c default=green
 		sleep 0.7
 	done
 done
diff --git a/lib/hollywood/htop b/lib/hollywood/htop
index 38d6f5d..54dbf3f 100755
--- a/lib/hollywood/htop
+++ b/lib/hollywood/htop
@@ -16,7 +16,7 @@
 
 command -v htop >/dev/null 2>&1 || exit 1
 
-trap "pkill -f -9 lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
+trap "pkill -9 -f lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
 while true; do
 	htop
 done
diff --git a/lib/hollywood/jp2a b/lib/hollywood/jp2a
index 9d689fa..e1b645b 100755
--- a/lib/hollywood/jp2a
+++ b/lib/hollywood/jp2a
@@ -17,9 +17,9 @@
 command -v locate >/dev/null 2>&1 || exit 1
 command -v jp2a >/dev/null 2>&1 || exit 1
 
-trap "pkill -f -9 lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
+trap "pkill -9 -f lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
 while true; do
-	FILES=$(locate "/usr/*jpg" | sort -R | head -n 4096)
+	FILES=$(locate "/usr/*jpg" | gsort -R | head -n 4096)
 	for f in $FILES; do
 		[ -r "$f" ] || continue
 		[ -s "$f" ] || continue
diff --git a/lib/hollywood/logs b/lib/hollywood/logs
index 2ff037e..f58d5d5 100755
--- a/lib/hollywood/logs
+++ b/lib/hollywood/logs
@@ -16,7 +16,7 @@
 
 command -v ccze >/dev/null 2>&1 || exit 1
 
-trap "pkill -f -9 lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
+trap "pkill -9 -f lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
 while true; do
 	LOGS=$(find /var/log -type f -name "*.log" 2>/dev/null)
 	for log in $LOGS; do
diff --git a/lib/hollywood/man b/lib/hollywood/man
index 09587f0..21b1984 100755
--- a/lib/hollywood/man
+++ b/lib/hollywood/man
@@ -16,9 +16,9 @@
 
 command -v man >/dev/null 2>&1 || exit 1
 
-trap "pkill -f -9 lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
+trap "pkill -9 -f lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
 while true; do
-	if timeout --foreground 3s man $(ls /usr/share/man/man1/ | sort -R | head -n1 | sed "s/\.1\.gz.*$//"); then
+	if gtimeout --foreground 3s man $(ls /usr/share/man/man1/ | gsort -R | head -n1 | gsed "s/\.1\.gz.*$//"); then
 		reset
 		exit 0
 	fi
diff --git a/lib/hollywood/speedometer b/lib/hollywood/speedometer
index 3c892ce..67af7a4 100755
--- a/lib/hollywood/speedometer
+++ b/lib/hollywood/speedometer
@@ -16,7 +16,7 @@
 
 command -v speedometer >/dev/null 2>&1 || exit 1
 
-trap "pkill -f -9 lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
+trap "pkill -9 -f lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
 local interface Destination Gateway Flags RefCnt Use Metric Mask MTU Window IRTT
 while true; do
 	while read Iface Destination Gateway Flags RefCnt Use Metric Mask MTU Window IRTT; do
diff --git a/lib/hollywood/sshart b/lib/hollywood/sshart
index 1bc6520..e287292 100755
--- a/lib/hollywood/sshart
+++ b/lib/hollywood/sshart
@@ -17,12 +17,12 @@
 command -v ssh-keygen >/dev/null 2>&1 || exit 1
 command -v ccze >/dev/null 2>&1 || exit 1
 
-tmpdir=$(mktemp -d -t XXXXXX)
-trap "rm -rf $tmpdir 2>/dev/null && pkill -f -9 lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
+tmpdir=$(gmktemp -d -t XXXXXX)
+trap "rm -rf $tmpdir 2>/dev/null && pkill -9 -f lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
 
 while true; do
 	sleep 3 &
-	tmpfile=$(mktemp -p "$tmpdir" -t XXXXXX)
+	tmpfile=$(gmktemp -p "$tmpdir" -t XXXXXX)
 	rm -f $tmpfile
 	art=$(ssh-keygen -vvv -b 1024 -t dsa -N "" -f $tmpfile)
 	rm -f $tmpfile $tmpfile.pub
diff --git a/lib/hollywood/stat b/lib/hollywood/stat
index bd94d3d..66fa69f 100755
--- a/lib/hollywood/stat
+++ b/lib/hollywood/stat
@@ -17,9 +17,9 @@
 command -v stat >/dev/null 2>&1 || exit 1
 command -v ccze >/dev/null 2>&1 || exit 1
 
-trap "pkill -f -9 lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
+trap "pkill -9 -f lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
 while true; do
-	for f in $(find /sys /dev 2>/dev/null | sort -R | head -n 4096); do
+	for f in $(find /sys /dev 2>/dev/null | gsort -R | head -n 4096); do
 		stat "$f" | ccze -A -c default=yellow
 		sleep 0.8
 	done
diff --git a/lib/hollywood/tree b/lib/hollywood/tree
index 0db1d67..eab82dd 100755
--- a/lib/hollywood/tree
+++ b/lib/hollywood/tree
@@ -16,7 +16,7 @@
 
 command -v tree >/dev/null 2>&1 || exit 1
 
-trap "pkill -f -9 lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
+trap "pkill -9 -f lib/hollywood/ >/dev/null 2>&1" HUP INT QUIT TERM
 DIRS="/sys /dev"
 
 while true; do
