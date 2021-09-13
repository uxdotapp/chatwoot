require 'rails_helper'

describe Line::IncomingMessageService do
  let!(:line_channel) { create(:channel_line) }
  let(:params) do
    {
      'destination': '2342234234',
      'events': [
        {
          'replyToken': '0f3779fba3b349968c5d07db31eab56f',
          'type': 'message',
          'mode': 'active',
          'timestamp': 1_462_629_479_859,
          'source': {
            'type': 'user',
            'userId': 'U4af4980629'
          },
          'message': {
            'id': '325708',
            'type': 'text',
            'text': 'Hello, world'
          }
        },
        {
          'replyToken': '8cf9239d56244f4197887e939187e19e',
          'type': 'follow',
          'mode': 'active',
          'timestamp': 1_462_629_479_859,
          'source': {
            'type': 'user',
            'userId': 'U4af4980629'
          }
        }
      ]
    }.with_indifferent_access
  end

  describe '#perform' do
    context 'when valid text message params' do
      it 'creates appropriate conversations, message and contacts' do
        line_bot = double
        line_user_profile = double
        allow(Line::Bot::Client).to receive(:new).and_return(line_bot)
        allow(line_bot).to receive(:get_profile).and_return(line_user_profile)
        allow(line_user_profile).to receive(:body).and_return(
          {
            'displayName': 'LINE Test',
            'userId': 'U4af4980629',
            'pictureUrl': 'https://test.com'
          }.to_json
        )
        described_class.new(inbox: line_channel.inbox, params: params).perform
        expect(line_channel.inbox.conversations).not_to eq(0)
        expect(Contact.all.first.name).to eq('LINE Test')
        expect(line_channel.inbox.messages.first.content).to eq('Hello, world')
      end
    end
  end
end