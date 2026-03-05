class LibkrunEfi < Formula
  desc "Dynamic library providing KVM-based process isolation capabilities"
  homepage "https://github.com/containers/libkrun"
  url "https://github.com/containers/libkrun/archive/refs/tags/v1.17.4.tar.gz"
  sha256 "2708a3c207c5493ee02de1781836c2511e54eb280633fcc7058fee983a6c2fe3"
  license "Apache-2.0"

  depends_on "rust" => :build
  # Upstream only supports Hypervisor.framework on arm64
  depends_on arch: :arm64
  depends_on "dtc"
  depends_on "kozzi11/homebrew-krunkit/virglrenderer"

  def install
    system "touch", "init/init"
    system "make", "EFI=1", "GPU=1", "BLK=1", "NET=1"
    system "make", "EFI=1", "GPU=1", "BLK=1", "NET=1", "PREFIX=#{prefix}", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <libkrun.h>
      int main()
      {
         int c = krun_create_ctx();
         return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lkrun", "-o", "test"
    system "./test"
  end
end
