class CreateReservations < ActiveRecord::Migration
  def self.up
    create_table :reservations do |t|
      t.date :date
      t.boolean :availability, :default => "true"
      t.string :t0630
      t.string :t0637
      t.string :t0645
      t.string :t0652
      t.string :t0700
      t.string :t0707
      t.string :t0715
      t.string :t0723
      t.string :t0730
      t.string :t0737
      t.string :t0745
      t.string :t0752
      t.string :t0800
      t.string :t0807
      t.string :t0815
      t.string :t0823
      t.string :t0830
      t.string :t0837
      t.string :t0845
      t.string :t0852
      t.string :t0900
      t.string :t0907
      t.string :t0915
      t.string :t0923
      t.string :t0930
      t.string :t0937
      t.string :t0945
      t.string :t0952
      t.string :t1000
      t.string :t1007
      t.string :t1015
      t.string :t1023
      t.string :t1030
      t.string :t1037
      t.string :t1045
      t.string :t1052
      t.string :t1100
      t.string :t1107
      t.string :t1115
      t.string :t1123
      t.string :t1130
      t.string :t1137
      t.string :t1145
      t.string :t1152
      t.string :t1200
      t.string :t1207
      t.string :t1215
      t.string :t1223
      t.string :t1230
      t.string :t1237
      t.string :t1245
      t.string :t1252
      t.string :t1300
      t.string :t1307
      t.string :t1315
      t.string :t1323
      t.string :t1330
      t.string :t1337
      t.string :t1345
      t.string :t1352
      t.string :t1400
      t.string :t1407
      t.string :t1415
      t.string :t1423
      t.string :t1430
      t.string :t1437
      t.string :t1445
      t.string :t1452
      t.string :t1500
      t.string :t1507
      t.string :t1515
      t.string :t1523
      t.string :t1530
      t.string :t1537
      t.string :t1545
      t.string :t1552
      t.string :t1600
      t.timestamps
    end
  end

  def self.down
    drop_table :reservations
  end
end
