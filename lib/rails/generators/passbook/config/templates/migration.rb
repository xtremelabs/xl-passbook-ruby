
#  Copyright 2012 Xtreme Labs

#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.



# @private
class CreatePassbookRegistrations < ActiveRecord::Migration
  def change
    create_table :passbook_registrations do |t|
      t.string :uuid
      t.string :device_id
      t.string :push_token
      t.string :serial_number
      t.string :pass_type_id

      t.timestamps
    end
  end
end
