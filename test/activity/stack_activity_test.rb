activity org.ruboto.test_app.StackActivity

setup do |activity|
  start = Time.now
  loop do
    @text_view = activity.findViewById(42)
    break if @text_view || (Time.now - start > 60)
    sleep 1
  end
  assert @text_view
end

# ANDROID: 10, PLATFORM: 0.4.7,     JRuby: 1.7.0.dev      '28334966'         expected, but got '28335067'
# ANDROID: 15, PLATFORM: STANDALONE, JRuby: 1.7.0         '[28, 33, 51, 68]' expected, but got '[28, 33, 47, 64]'
# ANDROID: 16, PLATFORM: 0.4.8.dev, JRuby: 1.7.0.preview2 '[29, 34, 47, 64]' expected, but got '[28, 33, 47, 64]'
test('stack depth') do |activity|
  os_offset = {
      13 => [1]*4,
      15 => [0, 0, 1, 1],
      16 => [0, 0, 1, 1],
  }[android.os.Build::VERSION::SDK_INT] || [0, 0, 0, 0]
  if org.ruboto.JRubyAdapter.uses_platform_apk?
    jruby_offset = {
        '0.4.7' => [0, 0, 4, 4],
    }[org.ruboto.JRubyAdapter.platform_version_name] || [0, 0, 0, 0]
  else # STANDALONE
    jruby_offset = {
        /^1\.6/ => [0, 0, 4, 4],
        // => [0, 0, 0, 0],
    }.find{|k,v| org.jruby.runtime.Constants::VERSION =~ k}[1]
  end
  version_message ="ANDROID: #{android.os.Build::VERSION::SDK_INT}, PLATFORM: #{org.ruboto.JRubyAdapter.uses_platform_apk ? org.ruboto.JRubyAdapter.platform_version_name : 'STANDALONE'}, JRuby: #{org.jruby.runtime.Constants::VERSION}"
  assert_equal [28 + os_offset[0] + jruby_offset[0],
                33 + os_offset[1] + jruby_offset[1],
                46 + os_offset[2] + jruby_offset[2],
                63 + os_offset[3] + jruby_offset[3]], [activity.find_view_by_id(42).text.to_i,
                                                    activity.find_view_by_id(43).text.to_i,
                                                    activity.find_view_by_id(44).text.to_i,
                                                    activity.find_view_by_id(45).text.to_i], version_message
end
