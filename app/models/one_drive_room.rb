class OneDriveRoom
  require 'yaml'
  include ActiveAttr::Model

  # 認証URL
  AUTH_FORMAT = "https://oauth.live.com/authorize?client_id=%s&scope=%s&response_type=token&locale=ja&redirect_uri=%s"
  # 会員情報取得URL
  USER_FORMAT =  "https://apis.live.net/v5.0/me?access_token=%s"
  # フォルダ情報取得URL
  DIR_FORMAT = "https://apis.live.net/v5.0/%s/files?access_token=%s"
  # ルートフォルダ情報取得URL
  ROOT_FORMAT = "https://apis.live.net/v5.0/me/skydrive/files?access_token=%s"
  # ファイル情報取得URL
  FILE_FORMAT = "https://apis.live.net/v5.0/%s?access_token=%s"
  # ファイルダウンロードURL
  DOWNLOAD_FORMAT = "https://apis.live.net/v5.0/%s/content?suppress_redirects=true&access_token=%s"

  attribute :client_id
  attribute :client_secret
  attribute :redirect_url
  @token
  @user_info
  @dir_info
  @file_info

  def load_yaml
    config = YAML.load_file('config/cloud.yml')
    self.client_id     = config['onedrive']['client_id']
    self.client_secret = config['onedrive']['client_secret']
    self.redirect_url  = config['onedrive']['redirect_url']
  end

  def update_yaml(onedrive_params)
    config = YAML.load_file('config/cloud.yml')
    config['onedrive']['client_id'] = onedrive_params['client_id']
    config['onedrive']['client_secret'] = onedrive_params['client_secret']
    config['onedrive']['redirect_url']  = onedrive_params['redirect_url']
    open('config/cloud.yml', 'w') do |f|
      YAML.dump(config, f)
    end
  end

  # 認証用URL生成
  def get_auth_url
    scope = 'wl.skydrive_update'
    url   = AUTH_FORMAT % [self.client_id, scope, self.redirect_url]
  end

  # 会員情報取得
  def get_user_name()
    request_user if @user_info.blank?
    @user_info['name']
  end

  # フォルダ取得
  def get_dir(id)
    request_dir(id) if @dir_info.blank?
    @dir_info['data']
  end

  # ファイル取得
  def get_file_name(id)
    request_file(id) if @file_info.blank?
    @file_info['name']
  end

  # 親ディレクトリ取得
  def get_parent_dir(id)
    request_file(id) if @file_info.blank?
    @file_info['parent_id']
  end

  # ファイルダウンロード
  def download_file(id)
    url = DOWNLOAD_FORMAT % [id, @token]
    res = RestClient.get url
    file_url  = JSON.parse(res.body)['location']
    file_name = get_file_name(id)
    open("#{file_name}", 'wb') do |file|
      file << open(file_url).read
    end
  end

  def set_token(token)
    @token = token
  end

  private
  # 会員情報取得リクエスト
  def request_user()
    url = USER_FORMAT % @token
    res = RestClient.get url
    @user_info = JSON.parse(res.body)
  end

  # フォルダ取得
  def request_dir(id)
    if id.present?
      url = DIR_FORMAT % [id, @token]
    else
      url = ROOT_FORMAT % @token
    end
    res = RestClient.get url
    @dir_info = JSON.parse(res.body)
  end

  # ファイル取得リクエスト
  def request_file(id)
    url = FILE_FORMAT % [id, @token]
    res = RestClient.get url
    @file_info = JSON.parse(res.body)
  end

end
