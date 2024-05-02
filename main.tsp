import "@typespec/http";

@service({
    title: "Val Town API",
})
namespace ValTown;

using TypeSpec.Http;

model PaginatedList<T> {
    data: T[];
    links: {
        previous?: string;
        self: string;
        next?: string;
    };
}

model User {
    id: string;
    username: string;
    bio: string;
    profileImageUrl: string;
}

model BaseVal {
    id: string;
    author: Author;
    name: string;
    code: string;
    privacy: "public" | "unlisted" | "private";
    version: integer;
}

model FullVal extends BaseVal {
    readme: string;
    likeCount: integer;
    referenceCount: integer;
}

model Author {
    id: string;
    username: string;
}

@route("/v1/me")
namespace Me {
    @get op getMe(): {
        @statusCode statusCode: 200;
        @body user: User;
    } | {
        @statusCode statusCode: 401;
        @body _: string;
    };

    @route("/likes")
    namespace Likes {
        @get op listLikes(@query limit?: integer, @query offset?: integer): {
            @statusCode statusCode: 200;
            @body likes: PaginatedList<BaseVal>;
        } | {
            @statusCode statusCode: 401;
            @body _: string;
        };
    }

    @route("/comments")
    namespace Comments {
        model Comment {
            id: string;
            author: Author;
            comment: string;
            createdAt: string;
            val: BaseVal;
        }

        @get op listComments(@query limit?: integer, @query offset?: integer): {
            @statusCode statusCode: 200;
            @body comments: PaginatedList<Comment>;
        } | {
            @statusCode statusCode: 401;
            @body _: string;
        };
    }

    @route("/references")
    namespace References {
        model BaseValRef {
            id: string;
            name: string;
            author: Author;
        }

        model Reference {
            referencedAt: string;
            reference: BaseValRef;
            dependsOn: BaseValRef;
        }

        @get op listReferences(
            @query limit?: integer,
            @query offset?: integer,
        ): {
            @statusCode statusCode: 200;
            @body references: PaginatedList<Reference>;
        } | {
            @statusCode statusCode: 401;
        };
    }
}

@route("/v1/vals")
namespace Vals {
    model CreateValBody {
        name: string;
        code: string;
        privacy: "public" | "unlisted" | "private";
    }
    @post op createVal(@body body: CreateValBody): {
        @statusCode statusCode: 201;
        @body val: FullVal;
    } | {
        @statusCode statusCode: 400;
    } | {
        @statusCode statusCode: 401;
    };
    @get op listVals(@query limit?: integer, @query offset?: integer): {
        @statusCode statusCode: 200;
        @body vals: PaginatedList<FullVal>;
    } | {
        @statusCode statusCode: 401;
        @body _: string;
    };

    @get op getVal(@path valId: string): {
        @statusCode statusCode: 200;
        @body val: FullVal;
    } | {
        @statusCode statusCode: 404;
        @body _: string;
    };

    model EditValBody {
        name: string;
        code: string;
    }
    @put op editVal(@body body: EditValBody): {
        @statusCode statusCode: 200;
        @body val: FullVal;
    } | {
        @statusCode statusCode: 400;
    } | {
        @statusCode statusCode: 401;
        @body _: string;
    };
    @put op updateVal(@path valId: string, val: FullVal): FullVal;

    @delete op deleteVal(@path valId: string): {
        @statusCode statusCode: 204;
    } | {
        @statusCode statusCode: 401;
        @body _: string;
    };

    @route("/{valId}/versions")
    namespace Versions {
        @get op listVersions(
            @query limit?: integer,
            @query offset?: integer,
            @path valId: string,
        ): {
            @statusCode statusCode: 200;
            @body body: PaginatedList<FullVal>;
        };
        @post op createVersion(@path valId: string, val: FullVal): FullVal;
        @get op getVersion(
            @path valId: string,
            @path version: integer,
        ): FullVal;
        @delete op deleteVersion(
            @path valId: string,
            @path version: integer,
        ): void;
    }
}

@route("/v1/alias")
namespace UserAlias {
    @route("/{username}")
    @get
    op resolveUser(@path username: string): User;

    @route("/{username}/{valName}")
    @get
    op resolveVal(@path username: string, @path valName: string): FullVal;
}

@route("/v1/users/{userId}/vals")
@get
op listVals(
    @path userId: string,
    @query limit?: integer,
    @query offset?: integer,
): {
    @statusCode statusCode: 200;
    @body vals: PaginatedList<FullVal>;
} | {
    @statusCode statusCode: 404;
    @body _: string;
};

@route("/v1/search/vals")
@get
op searchVals(
    @query query: string,
    @query limit?: integer,
    @query offset?: integer,
): {
    @statusCode statusCode: 200;
    @body vals: PaginatedList<FullVal>;
};

@route("/v1/eval")
namespace Eval {
    @get op eval(@query code: string): {
        @statusCode statusCode: 200;
        @body body: unknown;
    } | {
        @statusCode statusCode: 400;
    } | {
        @statusCode statusCode: 500;
    };

    @post op evalPost(
        @body body: {
            code: string;
        },
    ): {
        @statusCode statusCode: 200;
        @body body: unknown;
    } | {
        @statusCode statusCode: 400;
    } | {
        @statusCode statusCode: 500;
    };
}
