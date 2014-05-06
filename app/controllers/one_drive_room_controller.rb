class OneDriveRoomController < ApplicationController
  require 'yaml'
  require 'json'
  require 'open-uri'
  before_action :set_onedrive

  def signin
    @auth_url = @onedrive.get_auth_url
    if (params[:token].present?)
      session[:token] = params[:token]
    end
  end

  def index
    # ユーザー情報取得
    @user_name = @onedrive.get_user_name()
    # フォルダ情報取得
    @datas = @onedrive.get_dir(params[:id])
    # フォルダ情報取得
    if (params[:id].present?)
      @parent = @onedrive.get_parent_dir(params[:id])
    end
  end

  def download
    # ユーザー情報取得
    @user_name = @onedrive.get_user_name()
    # ファイル情報取得
    @file_name = @onedrive.get_file_name(params[:id])
    # ファイルダウンロード
    @onedrive.download_file(params[:id])
    # フォルダ情報取得
    @parent = @onedrive.get_parent_dir(params[:id])
  end

  def show
  end

  def update
    respond_to do |format|
      if @onedrive.update_yaml(onedrive_params)
        format.html { redirect_to action: :show, notice: 'Onedrive was successfully updated.' }
        format.json { render :show, status: :ok, location: @onedrive }
      else
        format.html { render :edit }
        format.json { render json: @onedrive.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_onedrive
      @onedrive = OneDriveRoom.new
      @onedrive.load_yaml
      @onedrive.set_token(session[:token])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def onedrive_params
      params.require(:one_drive_room).permit(:client_id, :client_secret, :redirect_url)
    end
end
