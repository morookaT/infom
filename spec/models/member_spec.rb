# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Member, type: :model do
  let(:member) { Member.new(params) }
  let(:params) { {} }
  let(:already) { 'はすでに存在します' }
  let(:chara_limit) { 'は10文字以内で入力してください' }
  example 'first_name,last_name,sex,email,passwordがあれば有効な状態であること' do
    the_member = FactoryBot.create(:member)
    expect(the_member).to be_valid
  end
  example 'first_nameがなければ無効な状態であること' do
    params.merge!(first_name: nil)
    member.valid?
    expect(member.errors.details[:first_name].first[:error]).to eq(:blank)
  end
  example 'last_nameがなければ無効な状態であること' do
    params.merge!(last_name: nil)
    member.valid?
    expect(member.errors.details[:last_name].first[:error]).to eq(:blank)
  end
  example 'sexがなければ無効な状態であること' do
    params.merge!(sex: nil)
    member.valid?
    expect(member.errors.details[:sex].first[:error]).to eq(:blank)
  end
  example 'emailがなければ無効な状態であること' do
    params.merge!(email: nil)
    member.valid?
    expect(member.errors.details[:email].first[:error]).to eq(:blank)
  end
  example '重複したメールアドレスなら無効な状態であること' do
    FactoryBot.create(:member, email: 'test1@example.com')
    member = Member.new(
      first_name: 'あ',
      last_name: 'oao',
      email: 'test1@example.com',
      password: 'hogehogehogehoge',
      sex: 2
    )
    member.valid?
    expect(member.errors[:email]).to include(already)
  end
  example 'first_nameが10文字を超えたら無効な状態であること' do
    params.merge!(first_name: 'あいうえおかきくけこさ')
    member.valid?
    expect(member.errors[:first_name]).to include(chara_limit)
  end
  example 'last_nameが10文字を超えたら無効な状態であること' do
    params.merge!(last_name: 'あいうえおかきくけこさ')
    member.valid?
    expect(member.errors[:last_name]).to include(chara_limit)
  end
  example 'sexに３以上を入れたら無効な状態であること' do
    params.merge!(sex: 3)
    member.valid?
    expect(member.errors[:sex]).to include('は3より小さい値にしてください')
  end
  example ' sexに0を入れたら無効な状態であること ' do
    params.merge!(sex: 0)
    member.valid?
    expect(member.errors[:sex]).to include('は0より大きい値にしてください')
  end
  example 'passwordが６文字より少なかったら無効であること' do
    params.merge!(password: 'aiueo')
    member.valid?
    expect(member.errors[:password]).to include('は6文字以上で入力してください')
  end
  example 'introductionが70文字より大きい場合、無効な状態であること' do
    params.merge!(introduction: 'o' * 71)
    member.valid?
    expect(member.errors[:introduction]).to include('は70文字以内で入力してください')
  end
end
