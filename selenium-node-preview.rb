class SeleniumNodePreview < Formula
    desc "Browser automation for safari-preview testing purposes"
    homepage "https://www.seleniumhq.org/"
    url "https://selenium-release.storage.googleapis.com/3.141/selenium-server-standalone-3.141.59.jar"
    sha256 "acf71b77d1b66b55db6fb0bed6d8bae2bbd481311bcbedfeff472c0d15e8f3cb"
  
    bottle :unneeded
  
    def install
      rm_f etc/"selenium/nodeConfigPreview.json"
      (etc/"selenium/nodeConfigPreview.json").write <<~EOS
      {
        "capabilities":
        [
          {
            "browserName": "safari",
            "technologyPreview": true,
            "platform": "MAC",
            "maxInstances": 1,
            "seleniumProtocol": "WebDriver",
            "version": "13.0.5"
          }
        ],
        "proxy": "org.openqa.grid.selenium.proxy.DefaultRemoteProxy",
        "maxSession": 1,
        "port": 5556,
        "register": true,
        "registerCycle": 5000,
        "hub": "http://localhost:4444",
        "nodeStatusCheckTimeout": 5000,
        "nodePolling": 5000,
        "role": "node",
        "unregisterIfStillDownAfter": 60000,
        "downPollingLimit": 2,
        "debug": false,
        "servlets" : [],
        "withoutServlets": [],
        "custom": {}
      }
      EOS

      libexec.install "selenium-server-standalone-#{version}.jar"
      bin.write_jar_script libexec/"selenium-server-standalone-#{version}.jar", "selenium-node-preview"
    end
  
    plist_options :manual => "selenium-node-preview -port 5556 -role node"

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
          <string>node</string>
          <string>-nodeConfig</string>
          <string>#{etc}/selenium/nodeConfigPreview.json</string>
        </array>
        <key>ServiceDescription</key>
        <string>Selenium Server</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/selenium-node-preview-error.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/selenium-node-preview-output.log</string>
      </dict>
      </plist>
    EOS
    end
  
    test do
      selenium_version = shell_output("unzip -p #{libexec}/selenium-server-standalone-#{version}.jar META-INF/MANIFEST.MF | sed -nEe '/Selenium-Version:/p'")
      assert_equal "Selenium-Version: #{version}", selenium_version.strip
    end
  end
  