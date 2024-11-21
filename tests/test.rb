describe 'database' do
    def run_script(commands, delete_db=true)
        raw_output = nil
        db_file = "data.db"
        if  File.file?(db_file) and delete_db
            File.delete(db_file)
        end
        IO.popen("./bin/SimpleDB #{db_file}", "r+") do |pipe|
            commands.each do |command|
                pipe.puts command
            end

            pipe.close_write
            raw_output = pipe.gets(nil)
        end
        raw_output.split("\n")
    end

    it 'inserts and retrieves a row' do
        result = run_script([
            "insert 1 user1 user1@gmail.com",
            "select",
            ".exit",
        ])
        expect(result).to match_array([
            "db > Executed successfully!",
            "db > 1 - user1 - user1@gmail.com",
            "Executed successfully!",
            "db > Bye!",
        ])
    end

    it 'prints error message when table is full' do
        script = (1..1401).map do |i|
            "insert #{i} user#{i} person#{i}@gmail.com"
        end
        script << ".exit"
        result = run_script(script)
        expect(result[-2]).to eq("db > Error the table it's full!")
    end

    it 'allows inserting strings that are the maximum length' do
        long_username = "a"*32
        long_email = "a"*255
        script = [
            "insert 1 #{long_username} #{long_email}",
            "select",
            ".exit"
        ]
        
        result = run_script(script)
        expect(result).to match_array([
            "db > Executed successfully!",
            "db > 1 - #{long_username} - #{long_email}",
            "Executed successfully!",
            "db > Bye!",
        ])
    end

    it 'prints error message if strings are too long' do
        long_username = "a"*33
        long_email = "a"*256
        script = [
            "insert 1 #{long_username} #{long_email}",
            "select",
            ".exit"
        ]

        result = run_script(script)
        expect(result).to match_array([
            "db > Error String too long!",
            "db > Executed successfully!",
            "db > Bye!",
        ])
    end

    it 'prints error message if it is negative' do
        script = [
            "insert -1 unername1 username1@gmail.com",
            "select",
            ".exit",
        ]

        result = run_script(script)
        expect(result).to match_array([
            "db > Error ID can't be negative!",
            "db > Executed successfully!",
            "db > Bye!",
        ])
    end

    it 'Keep data after closing the program' do
        result1 = run_script([
            "insert 1 test_user test_user@gmail.com",
            ".exit",
        ])

        expect(result1).to match_array([
            "db > Executed successfully!",
            "db > Bye!",
        ])

        result2 = run_script([
            "select",
            ".exit",
        ],false)

        expect(result2).to match_array([
            "db > 1 - test_user - test_user@gmail.com",
            "Executed successfully!",
            "db > Bye!",
        ])
    end 
end