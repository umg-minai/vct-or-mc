(list (channel
        (name 'minai)
        (url "https://github.com/umg-minai/guix-minai.git")
        (branch "main")
        (commit
          "b8f25c02ecfdc3b36d35291ea33e2abb2634da15")
        (introduction
          (make-channel-introduction
            "4e47c0f12cf838335bf731b1947ea434923569e3"
            (openpgp-fingerprint
              "7EAB 7082 91D9 28E5 4387  47A7 F9F3 CB1B 50FB 607A"))))
      (channel
        (name 'guix)
        (url "https://git.savannah.gnu.org/git/guix.git")
        (branch "master")
        (commit
          "aaa12db63270c487e3be1963b0fdfe93fdb2544d")
        (introduction
          (make-channel-introduction
            "9edb3f66fd807b096b48283debdcddccfea34bad"
            (openpgp-fingerprint
              "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA")))))
