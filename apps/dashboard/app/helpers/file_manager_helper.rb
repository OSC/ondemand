module FileManagerHelper
    def entry_icon(entry)
        {
            :directory => 'fa-folder',
            :file      => 'fa-file',
            :link      => 'fa-link',
        }.fetch(entry.fs_type, 'fa-file')
    end

    def breadcrumbs(path)
        crumbs = path.split('/').select { |crumb| ! crumb.empty? }
        crumbs.map.with_index do |crumb, index|
            {
                :name => crumb,
                :uri => fs_link(Pathname.new('/').join(*crumbs.slice(0, index + 1).to_a))
            }
        end.tap do |arry|
            arry.prepend({
                :name => '/',
                :uri => fs_link('/')
            })
        end
    end

    # TODO: write test for case where we are attempting to access a dotdir/dotfile
    def fs_link(path)
        (Addressable::URI.parse(root_url) + 'fs/' + path.to_s.gsub(/^\//, '')).to_s
    end

    def can_upload_to?(path)
        Pathname.new(path).writable?
    end
end
