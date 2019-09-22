class SeleniumHub < Formula
    desc "Browser automation for testing purposes"
    homepage "https://www.seleniumhq.org/"
    url "https://selenium-release.storage.googleapis.com/3.141/selenium-server-standalone-3.141.59.jar"
    sha256 "acf71b77d1b66b55db6fb0bed6d8bae2bbd481311bcbedfeff472c0d15e8f3cb"
  
    bottle :unneeded
  
    def install
      rm_f etc/"selenium/hubConfig.json"
      (etc/"selenium/hubConfig.json").write <<~EOS
      {
        "port": 4444,
        "newSessionWaitTimeout": 25000,
        "servlets": [],
        "capabilityMatcher": "org.openqa.grid.internal.utils.DefaultCapabilityMatcher",
        "throwOnCapabilityNotPresent": true,
        "nodePolling": 5000,
        "cleanUpCycle": 5000,
        "browserTimeout": 120000,
        "timeout": 120000,
        "maxSession": 5
      }
      EOS

      libexec.install "selenium-server-standalone-#{version}.jar"
      bin.write_jar_script libexec/"selenium-server-standalone-#{version}.jar", "selenium-hub"
    end
  
    plist_options :manual => "selenium-hub -port 4444 -role hub"
  
    def plist; <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
        <key>ProgramArguments</key>
        <array>
          <string>/usr/bin/java</string>
          <string>-jar</string>
          <string>#{libexec}/selenium-server-standalone-#{version}.jar</string>
          <string>-role</string>
          <string>hub</string>
          <string>-hubConfig</string>
          <string>#{etc}/selenium/hubConfig.json</string>
        </array>
        <key>ServiceDescription</key>
        <string>Selenium Server</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/selenium-hub-error.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/selenium-hub-output.log</string>
      </dict>
      </plist>
    EOS
    end
  
    test do
      selenium_version = shell_output("unzip -p #{libexec}/selenium-server-standalone-#{version}.jar META-INF/MANIFEST.MF | sed -nEe '/Selenium-Version:/p'")
      assert_equal "Selenium-Version: #{version}", selenium_version.strip
    end
  end
  